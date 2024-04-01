defmodule BathLARPWeb.V1.AccountController do
  @moduledoc """
  Controller for handling account management.
  """
  use BathLARPWeb, :controller
  use OpenApiSpex.ControllerSpecs
  require Logger

  # We don't really want the Ecto stuff exposed to this layer of the
  # application, so we'll need to think about how to deal with this (which will
  # probably involve a general error-handling strategy for the app).
  alias Ecto.Changeset
  alias Plug.Conn
  alias BathLARPWeb.ErrorHelpers
  alias PowEmailConfirmation.Phoenix.Mailer
  alias BathLARPWeb.V1.Schemas.Account.{CreateAccountRequest, CreateAccountResponse}

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["accounts"]

  operation :create,
    summary: "Create account",
    description:
      "Create an account. Completing registration will require additional steps, detailed in the response.",
    request_body: {"Account parameters", "application/vnd.api+json", CreateAccountRequest},
    responses: %{
      accepted: {"Create account response", "application/vnd.api+json", CreateAccountResponse},
      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response(),
      internal_server_error: OpenApiSpex.JsonErrorResponse.response()
    }

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(%Conn{} = conn, %{}) do
    %{email: email, password: password} = Map.get(conn, :body_params).data.attributes

    conn
    |> Pow.Plug.create_user(%{
      email: email,
      password: password,
      password_confirmation: password
    })
    |> case do
      {:ok, account, conn} ->
        token = PowEmailConfirmation.Plug.sign_confirmation_token(conn, account)
        url = "https://www.bathlarp.co.uk/accounts/#{account.id}/confirmation/#{token}"
        unconfirmed_account = %{account | email: account.unconfirmed_email || account.email}
        email = Mailer.email_confirmation(conn, unconfirmed_account, url)

        conn |> Pow.Phoenix.Mailer.deliver(email)
        conn |> send_create_account_success()

      {:error, changeset, conn} ->
        changeset.errors
        |> case do
          [email: {"has already been taken", _opts}] ->
            # Send a success response to protect against enumeration attacks.
            conn |> send_create_account_success()

          _ ->
            errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
            Logger.error("Error creating account: #{inspect(errors)}")
            send_error_response(conn)
        end
    end
  end

  defp send_create_account_success(conn) do
    conn
    |> put_status(:accepted)
    |> json(%{
      data: %{
        type: "account-creation-request",
        id: UUID.uuid4(),
        attributes: %{
          next_step:
            Enum.join(
              [
                "If an account with the supplied address does not already exist, a confirmation",
                "e-mail will be sent to that address. Please use the link in the e-mail to confirm",
                "your address."
              ],
              " "
            )
        }
      }
    })
  end

  defp send_error_response(conn) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{
      errors: [
        %{
          title: "Internal server error",
          status: 500,
          detail: "An unexpected error has occurred."
        }
      ]
    })
  end
end
