defmodule BathLARPWeb.V1.AccountConfirmationController do
  @moduledoc """
  Controller for handling account confirmation.
  """
  use BathLARPWeb, :controller
  use OpenApiSpex.ControllerSpecs
  require Logger

  alias Plug.Conn
  alias BathLARP.Accounts.Account

  alias BathLARPWeb.V1.Schemas.AccountConfirmation.{
    CreateAccountConfirmationRequest,
    CreateAccountConfirmationResponse
  }

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true
  plug :load_account_from_confirmation_token
  plug :check_account_matches_id

  tags ["accounts"]

  operation :create,
    operation_id: "createAccountConfirmation",
    summary: "Create account confirmation",
    description:
      "Confirm that the e-mail address associated with a previously-created account has received a confirmation code.",
    parameters: [
      account_id: [
        in: :path,
        description: "Account ID",
        type: :string,
        example: "df54c235-d8bf-431f-9525-f91484935252"
      ]
    ],
    request_body:
      {"Account confirmation parameters", "application/vnd.api+json",
       CreateAccountConfirmationRequest},
    responses: %{
      created:
        {"Create account confirmation response", "application/vnd.api+json",
         CreateAccountConfirmationResponse},
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response(),
      internal_server_error: OpenApiSpex.JsonErrorResponse.response()
    }

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(%Conn{} = conn, %{}) do
    PowEmailConfirmation.Plug.confirm_email(conn, %{})
    |> case do
      {:ok, _result, conn} ->
        conn
        |> put_status(:created)
        |> json(%{
          data: %{
            type: "account-confirmation",
            id: UUID.uuid4()
          }
        })

      {:error, errors, conn} ->
        Logger.error("Error confirming account: #{inspect(errors)}")

        conn
        |> put_status(500)
        |> json(%{
          errors: [
            %{
              status: 500,
              title: "internal server error"
            }
          ]
        })
    end
  end

  defp load_account_from_confirmation_token(%Conn{} = conn, _opts) do
    token = Map.get(conn, :body_params).data.attributes.token

    case PowEmailConfirmation.Plug.load_user_by_token(conn, token) do
      {:ok, conn} ->
        conn

      {:error, conn} ->
        conn
        |> put_status(422)
        |> json(%{
          errors: [
            %{
              status: 422,
              title: "Invalid or expired token"
            }
          ]
        })
        |> halt()
    end
  end

  defp check_account_matches_id(
         %{
           path_params: %{"account_id" => account_id},
           assigns: %{confirm_email_user: %Account{id: account_id}}
         } = conn,
         _opts
       ),
       do: conn

  defp check_account_matches_id(conn, _opts),
    do:
      conn
      |> put_status(422)
      |> json(%{
        errors: [
          %{
            status: 422,
            title: "Invalid or expired token"
          }
        ]
      })
      |> halt()
end
