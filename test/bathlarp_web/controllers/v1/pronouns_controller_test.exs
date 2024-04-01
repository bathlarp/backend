defmodule BathLARPWeb.V1.PronounsControllerTest do
  use BathLARPWeb.ConnCase
  import OpenApiSpex.TestAssertions

  import BathLARP.SiteConfigurationFixtures

  alias BathLARP.{Repo, Accounts.Account}

  @password "secret1234"
  @session_params %{
    "data" => %{
      "type" => "session",
      "attributes" => %{"email" => "test@example.com", "password" => @password}
    }
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/vnd.api+json")}
  end

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

  defp confirm_account(%{conn: conn, account: account}) do
    PowEmailConfirmation.Ecto.Context.confirm_email(account, %{}, otp_app: :bathlarp)
    authed_conn = post(conn, ~p"/v1/session", @session_params)
    assert json_response(authed_conn, 201)

    {:ok, access_token: authed_conn.private[:api_access_token]}
  end

  defp set_headers(%{conn: conn, access_token: token}) do
    conn =
      Plug.Conn.merge_req_headers(conn, [
        {"accept", "application/vnd.api+json"},
        {"content-type", "application/vnd.api+json"},
        {"authorization", token}
      ])

    {:ok, conn: conn}
  end

  setup :create_account
  setup :confirm_account
  setup :set_headers

  describe "index" do
    test "lists all pronouns with no pronoun sets defined", %{conn: conn} do
      conn = get(conn, ~p"/v1/pronouns")
      assert json = json_response(conn, 200)
      assert json["data"] == []

      assert_schema json, "ListPronounsResponse", BathLARPWeb.ApiSpec.spec()
    end

    test "lists all pronouns with pronoun sets defined", %{conn: conn} do
      create_pronouns(nil)
      conn = get(conn, ~p"/v1/pronouns")
      assert json = json_response(conn, 200)
      assert length(json["data"]) == 1

      assert_schema json, "ListPronounsResponse", BathLARPWeb.ApiSpec.spec()
    end

    test "errors when not authenticated", %{conn: conn} do
      conn = Plug.Conn.delete_req_header(conn, "authorization")
      conn = get(conn, ~p"/v1/pronouns")
      assert json_response(conn, 401)
    end
  end

  defp create_pronouns(_) do
    pronouns = pronouns_fixture()
    %{pronouns: pronouns}
  end
end
