defmodule BathLARPWeb.V1.SessionControllerTest do
  use BathLARPWeb.ConnCase
  import OpenApiSpex.TestAssertions

  alias BathLARP.{Repo, Accounts.Account}

  @password "secret1234"
  @valid_params %{
    "data" => %{
      "type" => "session",
      "attributes" => %{"email" => "test@example.com", "password" => @password}
    }
  }
  @invalid_params %{
    "data" => %{
      "type" => "session",
      "attributes" => %{"email" => "test@example.com", "password" => "invalid"}
    }
  }

  defp create_account(_ctx) do
    account =
      %Account{}
      |> Account.changeset(%{
        email: "test@example.com",
        password: @password,
        password_confirmation: @password
      })
      |> Repo.insert!()

    {:ok, account: account}
  end

  defp valid_renewal_params(session_id),
    do: %{
      "data" => %{
        "id" => session_id,
        "type" => "session"
      }
    }

  defp set_headers(%{conn: conn}) do
    conn =
      Plug.Conn.merge_req_headers(conn, [
        {"accept", "application/vnd.api+json"},
        {"content-type", "application/vnd.api+json"}
      ])

    {:ok, conn: conn}
  end

  setup :create_account
  setup :set_headers

  describe "create/2" do
    test "with valid params", %{conn: conn, account: account} do
      res_conn = post(conn, ~p"/v1/session", @valid_params)
      assert json = json_response(res_conn, 401)
      assert hd(json["errors"])["title"] == "Unauthorized"
      assert hd(json["errors"])["detail"] == "Account email is not confirmed"
      assert hd(json["errors"])["status"] == "401"

      PowEmailConfirmation.Ecto.Context.confirm_email(account, %{}, otp_app: :bathlarp)
      res_conn = post(conn, ~p"/v1/session", @valid_params)

      assert json = json_response(res_conn, 201)
      assert json["data"]["attributes"]["access_token"]
      assert json["data"]["attributes"]["renewal_token"]

      api_spec = BathLARPWeb.ApiSpec.spec()
      assert_schema json, "CreateSessionResponse", api_spec
    end

    test "with invalid params", %{conn: conn} do
      conn = post(conn, ~p"/v1/session", @invalid_params)

      assert json = json_response(conn, 401)
      assert hd(json["errors"])["title"] == "Unauthorized"
      assert hd(json["errors"])["detail"] == "Invalid email or password"
      assert hd(json["errors"])["status"] == "401"
    end
  end

  describe "update/2" do
    setup %{conn: conn, account: account} do
      PowEmailConfirmation.Ecto.Context.confirm_email(account, %{}, otp_app: :bathlarp)
      authed_conn = post(conn, ~p"/v1/session", @valid_params)
      assert json = json_response(authed_conn, 201)
      session_id = json["data"]["id"]

      {:ok, renewal_token: authed_conn.private[:api_renewal_token], session_id: session_id}
    end

    test "with valid authorization header", %{
      conn: conn,
      renewal_token: token,
      session_id: session_id
    } do
      conn =
        conn
        |> Plug.Conn.put_req_header("authorization", token)
        |> patch(~p"/v1/session", valid_renewal_params(session_id))

      assert json = json_response(conn, 200)
      assert json["data"]["attributes"]["access_token"]
      assert json["data"]["attributes"]["renewal_token"]

      api_spec = BathLARPWeb.ApiSpec.spec()
      assert_schema json, "UpdateSessionResponse", api_spec
    end

    test "with invalid authorization header", %{conn: conn, session_id: session_id} do
      conn =
        conn
        |> Plug.Conn.put_req_header("authorization", "invalid")
        |> patch(~p"/v1/session", valid_renewal_params(session_id))

      assert json = json_response(conn, 401)
      assert hd(json["errors"])["title"] == "Unauthorized"
      assert hd(json["errors"])["detail"] == "Invalid token"
      assert hd(json["errors"])["status"] == "401"
    end
  end

  describe "delete/2" do
    setup %{conn: conn} do
      authed_conn = post(conn, ~p"/v1/session", @valid_params)

      {:ok, access_token: authed_conn.private[:api_access_token]}
    end

    test "invalidates", %{conn: conn, access_token: token} do
      conn =
        conn
        |> Plug.Conn.put_req_header("authorization", token)
        |> delete(~p"/v1/session")

      assert response(conn, 204) =~ ""
    end
  end
end
