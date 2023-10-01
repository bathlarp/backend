defmodule BathLARPWeb.V1.RegistrationControllerTest do
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
      conn = post(conn, ~p"/v1/registration", @valid_params)

      assert json = json_response(conn, 200)
      assert json["data"]["access_token"]
      assert json["data"]["renewal_token"]
    end

    test "with invalid params", %{conn: conn} do
      conn = post(conn, ~p"/v1/registration", @invalid_params)

      assert json = json_response(conn, 500)
      assert json["error"]["message"] == "Couldn't create account"
      assert json["error"]["status"] == 500
      assert json["error"]["errors"]["password_confirmation"] == ["does not match confirmation"]
      assert json["error"]["errors"]["email"] == ["has invalid format"]
    end
  end
end
