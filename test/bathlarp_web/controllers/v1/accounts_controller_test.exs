defmodule BathLARPWeb.V1.AccountsControllerTest do
  use BathLARPWeb.ConnCase

  @password "secret1234"

  describe "create/2" do
    @valid_params %{
      "account" => %{
        "email" => "test@example.com",
        "password" => @password,
        "password_confirmation" => @password
      }
    }
    @invalid_params %{
      "account" => %{"email" => "invalid", "password" => @password, "password_confirmation" => ""}
    }

    test "with valid params", %{conn: conn} do
      conn = post(conn, ~p"/v1/accounts", @valid_params)

      assert json = json_response(conn, 202)
    end

    test "with invalid params", %{conn: conn} do
      conn = post(conn, ~p"/v1/accounts", @invalid_params)

      assert json = json_response(conn, 500)
      assert hd(json["errors"])["title"] == "Failed to create account"
      assert hd(json["errors"])["status"] == 500

      assert hd(json["errors"])["meta"]["password_confirmation"] == [
               "does not match confirmation"
             ]

      assert hd(json["errors"])["meta"]["email"] == ["has invalid format"]
    end
  end
end
