defmodule BathLARPWeb.V1.AccountsController do
  @moduledoc """
  Controller for handling account management.
  """
  use BathLARPWeb, :controller

  # We don't really want the Ecto stuff exposed to this layer of the
  # application, so we'll need to think about how to deal with this (which will
  # probably involve a general error-handling strategy for the app).
  alias Ecto.Changeset
  alias Plug.Conn
  alias BathLARPWeb.ErrorHelpers
  alias PowEmailConfirmation.Phoenix.Mailer

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"account" => account_params}) do
    conn
    |> Pow.Plug.create_user(account_params)
    |> case do
      {:ok, account, conn} ->
        token = PowEmailConfirmation.Plug.sign_confirmation_token(conn, account)
        url = "https://www.bathlarp.co.uk/accounts/#{account.id}/confirmation/#{token}"
        unconfirmed_account = %{account | email: account.unconfirmed_email || account.email}
        email = Mailer.email_confirmation(conn, unconfirmed_account, url)

        conn |> Pow.Phoenix.Mailer.deliver(email)

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
                    "A confirmation e-mail has been sent to the supplied address.",
                    "Please use the link in the e-mail to confirm your address."
                  ],
                  " "
                )
            }
          }
        })

      {:error, changeset, conn} ->
        errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)

        conn
        |> put_status(500)
        |> json(%{
          errors: [
            %{
              title: "Failed to create account",
              status: 500,
              meta: errors
            }
          ]
        })
    end
  end
end
