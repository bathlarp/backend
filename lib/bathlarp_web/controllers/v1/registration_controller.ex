defmodule BathLARPWeb.V1.RegistrationController do
  @moduledoc """
  Controller for handling account registration.
  """
  use BathLARPWeb, :controller

  # We don't really want the Ecto stuff exposed to this layer of the
  # application, so we'll need to think about how to deal with this (which will
  # probably involve a general error-handling strategy for the app).
  alias Ecto.Changeset
  alias Plug.Conn
  alias BathLARPWeb.ErrorHelpers

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"account" => account_params}) do
    conn
    |> Pow.Plug.create_user(account_params)
    |> case do
      {:ok, _account, conn} ->
        json(conn, %{
          data: %{
            access_token: conn.private.api_access_token,
            renewal_token: conn.private.api_renewal_token
          }
        })

      {:error, changeset, conn} ->
        errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)

        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: "Couldn't create account", errors: errors}})
    end
  end
end
