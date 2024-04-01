defmodule BathLARPWeb.V1.SessionController do
  @moduledoc """
  Controller for handling authentication.
  """
  use BathLARPWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias BathLARPWeb.APIAuthPlug
  alias Plug.Conn

  alias BathLARPWeb.V1.Schemas.Session.{
    CreateSessionRequest,
    CreateSessionResponse,
    UpdateSessionRequest,
    UpdateSessionResponse
  }

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["sessions"]

  operation :create,
    summary: "Create session",
    description: "Create a session on the BathLARP API server and obtain access tokens.",
    request_body: {"Session parameters", "application/vnd.api+json", CreateSessionRequest},
    responses: %{
      created: {"Create session response", "application/vnd.api+json", CreateSessionResponse},
      unauthorized: OpenApiSpex.JsonErrorResponse.response()
    }

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(%Conn{} = conn, %{}) do
    %{email: email, password: password} = Map.get(conn, :body_params).data.attributes

    with {:ok, conn} <-
           Pow.Plug.authenticate_user(conn, %{"email" => email, "password" => password}),
         {:ok, conn} <- check_confirmed_or_no_account(conn) do
      conn |> send_session_data(:created)
    else
      {:error, conn} ->
        conn |> invalid_email_or_password()

      {:error, :unconfirmed, conn} ->
        conn |> unconfirmed()
    end
  end

  operation :update,
    summary: "Update session",
    description: "Refresh a session on the BathLARP API and obtain fresh access tokens.",
    request_body: {"Session parameters", "application/vnd.api+json", UpdateSessionRequest},
    responses: %{
      ok: {"Update session response", "application/vnd.api+json", UpdateSessionResponse},
      unauthorized: OpenApiSpex.JsonErrorResponse.response()
    }

  @spec update(Conn.t(), map()) :: Conn.t()
  def update(%Conn{} = conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> APIAuthPlug.renew(config)
    |> case do
      {conn, nil} ->
        conn |> invalid_token()

      {conn, _account} ->
        conn |> send_session_data(:ok)
    end
  end

  operation :delete,
    summary: "Delete session",
    description: "Destroy a session on the BathLARP API and log out.",
    responses: %{
      no_content: {"Delete session response", nil, nil},
      unauthorized: OpenApiSpex.JsonErrorResponse.response()
    }

  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> put_status(:no_content)
    |> send_resp(204, "")
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

  defp send_session_data(conn, status) do
    conn
    |> put_status(status)
    |> json(%{
      data: %{
        type: "session",
        id: UUID.uuid4(),
        attributes: %{
          access_token: conn.private.api_access_token,
          renewal_token: conn.private.api_renewal_token
        }
      }
    })
  end

  defp invalid_email_or_password(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      errors: [
        %{
          status: "401",
          title: "Unauthorized",
          detail: "Invalid email or password"
        }
      ]
    })
  end

  defp unconfirmed(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      errors: [
        %{
          status: "401",
          title: "Unauthorized",
          detail: "Account email is not confirmed"
        }
      ]
    })
  end

  defp invalid_token(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      errors: [
        %{
          status: "401",
          title: "Unauthorized",
          detail: "Invalid token"
        }
      ]
    })
  end
end
