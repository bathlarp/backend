defmodule BathLARPWeb.V1.SessionControllerTest do
  use BathLARPWeb.ConnCase

  alias BathLARP.{Repo, Accounts.Account}

  @password "secret1234"
  @valid_params %{"account" => %{"email" => "test@example.com", "password" => @password}}
  @invalid_params %{"account" => %{"email" => "test@example.com", "password" => "invalid"}}

  setup do
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

  describe "create/2" do
    test "with valid params", %{conn: conn, account: account} do
      res_conn = post(conn, ~p"/v1/session", @valid_params)
      assert json = json_response(res_conn, 401)
      assert json["error"]["message"] == "User is not confirmed"
      assert json["error"]["status"] == 401

      PowEmailConfirmation.Ecto.Context.confirm_email(account, %{}, otp_app: :bathlarp)
      res_conn = post(conn, ~p"/v1/session", @valid_params)

      assert json = json_response(res_conn, 200)
      assert json["data"]["access_token"]
      assert json["data"]["renewal_token"]
    end

    test "with invalid params", %{conn: conn} do
      conn = post(conn, ~p"/v1/session", @invalid_params)

      assert json = json_response(conn, 401)
      assert json["error"]["message"] == "Invalid email or password"
      assert json["error"]["status"] == 401
    end
  end

  describe "update/2" do
    setup %{conn: conn} do
      authed_conn = post(conn, ~p"/v1/session", @valid_params)

      {:ok, renewal_token: authed_conn.private[:api_renewal_token]}
    end

    test "with valid authorization header", %{conn: conn, renewal_token: token} do
      conn =
        conn
        |> Plug.Conn.put_req_header("authorization", token)
        |> patch(~p"/v1/session")

      assert json = json_response(conn, 200)
      assert json["data"]["access_token"]
      assert json["data"]["renewal_token"]
    end

    test "with invalid authorization header", %{conn: conn} do
      conn =
        conn
        |> Plug.Conn.put_req_header("authorization", "invalid")
        |> patch(~p"/v1/session")

      assert json = json_response(conn, 401)
      assert json["error"]["message"] == "Invalid token"
      assert json["error"]["status"] == 401
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

      assert json = json_response(conn, 200)
      assert json["data"] == %{}
    end
  end
end
