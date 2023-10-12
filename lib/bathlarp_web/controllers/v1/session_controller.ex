defmodule BathLARPWeb.V1.SessionController do
  @moduledoc """
  Controller for handling authentication.
  """
  use BathLARPWeb, :controller

  alias BathLARPWeb.APIAuthPlug
  alias Plug.Conn

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"account" => account_params}) do
    with {:ok, conn} <- Pow.Plug.authenticate_user(conn, account_params),
         {:ok, conn} <- check_confirmed_or_no_account(conn) do
      json(conn, %{
        data: %{
          access_token: conn.private.api_access_token,
          renewal_token: conn.private.api_renewal_token
        }
      })
    else
      {:error, conn} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid email or password"}})

      {:error, :unconfirmed, conn} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "User is not confirmed"}})
    end
  end

  @spec update(Conn.t(), map()) :: Conn.t()
  def update(conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> APIAuthPlug.renew(config)
    |> case do
      {conn, nil} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid token"}})

      {conn, _account} ->
        json(conn, %{
          data: %{
            access_token: conn.private.api_access_token,
            renewal_token: conn.private.api_renewal_token
          }
        })
    end
  end

  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> json(%{data: %{}})
  end

  @spec check_confirmed_or_no_account(Conn.t()) ::
          {:ok, Conn.t()} | {:error, :unconfirmed, Conn.t()}
  defp check_confirmed_or_no_account(conn) do
    with user when not is_nil(user) <- Pow.Plug.current_user(conn),
         true <- PowEmailConfirmation.Plug.email_unconfirmed?(conn) do
      {:error, :unconfirmed, conn}
    else
      _ -> {:ok, conn}
    end
  end
end
