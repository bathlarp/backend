defmodule BathLARPWeb.APIAuthPlug do
  @moduledoc """
  Plug to handle access token management.
  """
  use Pow.Plug.Base

  alias Plug.Conn
  alias Pow.{Config, Plug, Store.CredentialsCache}
  alias PowPersistentSession.Store.PersistentSessionCache

  @doc """
  Fetches the account from an access token.
  """
  @impl true
  @spec fetch(Conn.t(), Config.t()) :: {Conn.t(), map() | nil}
  def fetch(conn, config) do
    with {:ok, signed_token} <- fetch_access_token(conn),
         {:ok, token} <- verify_token(conn, signed_token, config),
         {account, _metadata} <- CredentialsCache.get(store_config(config), token) do
      {conn, account}
    else
      _any -> {conn, nil}
    end
  end

  @doc """
  Creates an access and renewal token for the account.

  The tokens are added to the `conn.private` as `:api_access_token` and
  `:api_renewal_token`. The renewal token is stored in the access token
  metadata and vice versa. The expiry timestamp of the access token is
  also stored as `:api_access_expiry` so it can be referenced by the
  frontend later.
  """
  @impl true
  @spec create(Conn.t(), map(), Config.t()) :: {Conn.t(), map()}
  def create(conn, account, config) do
    store_config = store_config(config)
    access_token = Pow.UUID.generate()
    renewal_token = Pow.UUID.generate()
    token_conf = Application.get_env(:bathlarp, BathLARPWeb.APIAuthPlug)
    access_expiry = Keyword.get(token_conf, :access_expiry) |> String.to_integer()
    refresh_expiry = Keyword.get(token_conf, :refresh_expiry) |> String.to_integer()

    conn =
      conn
      |> Conn.put_private(:api_access_token, sign_token(conn, access_token, config))
      |> Conn.put_private(:api_renewal_token, sign_token(conn, renewal_token, config))
      |> Conn.put_private(
        :api_access_expiry,
        DateTime.utc_now() |> DateTime.add(access_expiry, :minute)
      )
      |> Conn.register_before_send(fn conn ->
        # The store caches will use their default `:ttl` setting. To change the
        # `:ttl`, `Keyword.put(store_config, :ttl, :timer.minutes(10))` can be
        # passed in as the first argument instead of `store_config`.
        CredentialsCache.put(
          Keyword.put(store_config, :ttl, :timer.minutes(access_expiry)),
          access_token,
          {account, [renewal_token: renewal_token]}
        )

        PersistentSessionCache.put(
          Keyword.put(store_config, :ttl, :timer.hours(refresh_expiry * 24)),
          renewal_token,
          {account, [access_token: access_token]}
        )

        conn
      end)

    {conn, account}
  end

  @doc """
  Delete the access token from the cache.

  The renewal token is deleted by fetching it from the access token metadata.
  """
  @impl true
  @spec delete(Conn.t(), Config.t()) :: Conn.t()
  def delete(conn, config) do
    store_config = store_config(config)

    with {:ok, signed_token} <- fetch_access_token(conn),
         {:ok, token} <- verify_token(conn, signed_token, config),
         {_account, metadata} <- CredentialsCache.get(store_config, token) do
      Conn.register_before_send(conn, fn conn ->
        PersistentSessionCache.delete(store_config, metadata[:renewal_token])
        CredentialsCache.delete(store_config, token)

        conn
      end)
    else
      _any -> conn
    end
  end

  @doc """
  Creates new tokens using the renewal token.

  The access token, if any, will be deleted by fetching it from the renewal
  token metadata. The renewal token will be deleted from the store after the
  it has been fetched.
  """
  @spec renew(Conn.t(), Config.t()) :: {Conn.t(), map() | nil}
  def renew(conn, config) do
    store_config = store_config(config)

    with {:ok, signed_token} <- fetch_access_token(conn),
         {:ok, token} <- verify_token(conn, signed_token, config),
         {account, metadata} <- PersistentSessionCache.get(store_config, token) do
      {conn, account} = create(conn, account, config)

      conn =
        Conn.register_before_send(conn, fn conn ->
          CredentialsCache.delete(store_config, metadata[:access_token])
          PersistentSessionCache.delete(store_config, token)

          conn
        end)

      {conn, account}
    else
      _any -> {conn, nil}
    end
  end

  defp sign_token(conn, token, config) do
    Plug.sign_token(conn, signing_salt(), token, config)
  end

  defp signing_salt(), do: Atom.to_string(__MODULE__)

  defp fetch_access_token(conn) do
    case Conn.get_req_header(conn, "authorization") do
      [token | _rest] -> {:ok, String.replace_prefix(token, "Bearer ", "")}
      _any -> :error
    end
  end

  defp verify_token(conn, token, config),
    do: Plug.verify_token(conn, signing_salt(), token, config)

  defp store_config(config) do
    backend = Config.get(config, :cache_store_backend, Pow.Store.Backend.EtsCache)

    [backend: backend, pow_config: config]
  end
end
