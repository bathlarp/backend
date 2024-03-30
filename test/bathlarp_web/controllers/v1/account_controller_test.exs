defmodule BathLARPWeb.V1.AccountControllerTest do
  use BathLARPWeb.ConnCase
  import OpenApiSpex.TestAssertions

  @password "secret1234"

  describe "create/2" do
    @valid_params %{
      "data" => %{
        "type" => "account",
        "attributes" => %{
          "email" => "test@example.com",
          "password" => @password
        }
      }
    }
    @invalid_email_params %{
      "data" => %{
        "type" => "account",
        "attributes" => %{
          "email" => "invalid",
          "password" => @password
        }
      }
    }
    @invalid_password_params %{
      "data" => %{
        "type" => "account",
        "attributes" => %{
          "email" => "test@example.com",
          "password" => "1234567"
        }
      }
    }
    @missing_email_params %{
      "data" => %{
        "type" => "account",
        "attributes" => %{
          "password" => @password
        }
      }
    }
    @missing_password_params %{
      "data" => %{
        "type" => "account",
        "attributes" => %{
          "email" => "test@example.com"
        }
      }
    }
    @multiple_errors_params %{
      "data" => %{
        "type" => "account",
        "attributes" => %{
          "email" => "invalid",
          "password" => "1234567"
        }
      }
    }

    test "with valid params", %{conn: conn} do
      conn = post(conn, ~p"/v1/accounts", @valid_params)

      assert json = json_response(conn, 202)

      api_spec = BathLARPWeb.ApiSpec.spec()
      assert_schema json, "CreateAccountResponse", api_spec
    end

    test "with invalid email", %{conn: conn} do
      conn = post(conn, ~p"/v1/accounts", @invalid_email_params)

      assert json = json_response(conn, 422)
      assert hd(json["errors"])["title"] == "Invalid value"
      assert String.contains?(hd(json["errors"])["detail"], "Invalid format")
      assert hd(json["errors"])["source"]["pointer"] == "/data/attributes/email"
    end

    test "with invalid password", %{conn: conn} do
      conn = post(conn, ~p"/v1/accounts", @invalid_password_params)

      assert json = json_response(conn, 422)
      assert hd(json["errors"])["title"] == "Invalid value"

      assert String.contains?(
               hd(json["errors"])["detail"],
               "String length is smaller than minLength: 8"
             )

      assert hd(json["errors"])["source"]["pointer"] == "/data/attributes/password"
    end

    test "with missing email", %{conn: conn} do
      conn = post(conn, ~p"/v1/accounts", @missing_email_params)

      assert json = json_response(conn, 422)
      assert hd(json["errors"])["title"] == "Invalid value"
      assert hd(json["errors"])["detail"] == "Missing field: email"
      assert hd(json["errors"])["source"]["pointer"] == "/data/attributes/email"
    end

    test "with missing password", %{conn: conn} do
      conn = post(conn, ~p"/v1/accounts", @missing_password_params)

      assert json = json_response(conn, 422)
      assert hd(json["errors"])["title"] == "Invalid value"
      assert hd(json["errors"])["detail"] == "Missing field: password"
      assert hd(json["errors"])["source"]["pointer"] == "/data/attributes/password"
    end

    test "with multiple errors", %{conn: conn} do
      conn = post(conn, ~p"/v1/accounts", @multiple_errors_params)

      assert json = json_response(conn, 422)
      assert length(json["errors"]) == 2
    end
  end
end
