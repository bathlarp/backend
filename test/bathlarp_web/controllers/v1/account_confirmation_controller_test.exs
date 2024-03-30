defmodule BathLARPWeb.V1.AccountConfirmationControllerTest do
  use BathLARPWeb.ConnCase

  alias BathLARP.{Repo, Accounts.Account}
  import Ecto.Query, only: [from: 2]
  import OpenApiSpex.TestAssertions

  @password "secret1234"

  describe "Account Confirmation controller" do
    @valid_email "test@example.com"
    @other_valid_email "other@example.com"

    @valid_params %{
      "data" => %{
        "type" => "account",
        "attributes" => %{
          "email" => @valid_email,
          "password" => @password
        }
      }
    }

    @other_valid_params %{
      "data" => %{
        "type" => "account",
        "attributes" => %{
          "email" => @other_valid_email,
          "password" => @password
        }
      }
    }

    setup %{conn: conn} do
      post(conn, ~p"/v1/accounts", @other_valid_params)
      conn = post(conn, ~p"/v1/accounts", @valid_params)
      account = Repo.one(from a in Account, where: a.email == @valid_email)
      other_account = Repo.one(from a in Account, where: a.email == @other_valid_email)
      email_token = PowEmailConfirmation.Plug.sign_confirmation_token(conn, account)

      {:ok, account: account, other_account: other_account, token: email_token}
    end

    test "confirms account when token is valid", %{conn: conn, account: account, token: token} do
      conn =
        post(conn, ~p"/v1/accounts/#{account.id}/confirmation", %{
          data: %{
            type: "account-confirmation",
            attributes: %{token: token}
          }
        })

      assert json = json_response(conn, 201)

      api_spec = BathLARPWeb.ApiSpec.spec()
      assert_schema json, "CreateAccountConfirmationResponse", api_spec
    end

    test "errors when token is invalid", %{conn: conn, account: account} do
      conn =
        post(conn, ~p"/v1/accounts/#{account.id}/confirmation", %{
          data: %{
            type: "account-confirmation",
            attributes: %{token: "invalid"}
          }
        })

      assert json = json_response(conn, 422)
      assert hd(json["errors"])["title"] == "Invalid or expired token"
    end

    test "errors when token is for a different account",
         %{conn: conn, other_account: other_account, token: token} do
      conn =
        post(conn, ~p"/v1/accounts/#{other_account.id}/confirmation", %{
          data: %{
            type: "account-confirmation",
            attributes: %{token: token}
          }
        })

      assert json = json_response(conn, 422)
      assert hd(json["errors"])["title"] == "Invalid or expired token"
    end
  end
end
