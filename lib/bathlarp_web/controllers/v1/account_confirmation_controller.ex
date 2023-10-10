defmodule BathLARPWeb.V1.AccountConfirmationController do
  use BathLARPWeb, :controller

  alias BathLARP.Accounts.Account

  plug :load_account_from_confirmation_token
  plug :check_account_matches_id

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, _) do
    PowEmailConfirmation.Plug.confirm_email(conn, %{})
    |> case do
      {:ok, _result, conn} ->
        conn
        |> send_resp(:no_content, "")

      {:error, _errors, conn} ->
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

  defp load_account_from_confirmation_token(
         %{params: %{"data" => %{"attributes" => %{"token" => token}}}} = conn,
         _opts
       ) do
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
              title: "invalid or expired token"
            }
          ]
        })
        |> halt()
    end
  end

  defp check_account_matches_id(
         %{
           params: %{"accounts_id" => account_id},
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
            title: "invalid or expired token"
          }
        ]
      })
      |> halt()
end
