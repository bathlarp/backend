defmodule BathLARPWeb.APIAuthPlugTest do
  use BathLARPWeb.ConnCase
  doctest BathLARPWeb.APIAuthPlug

  alias BathLARPWeb.{APIAuthPlug, Endpoint}
  alias BathLARP.{Repo, Accounts.Account}
  alias Plug.Conn

  @pow_config [otp_app: :bathlarp]

  setup %{conn: conn} do
    conn = %{conn | secret_key_base: Endpoint.config(:secret_key_base)}
    account = Repo.insert!(%Account{id: UUID.uuid4(), email: "test@example.com"})

    {:ok, conn: conn, account: account}
  end

  test "can create, fetch, renew, and delete session", %{conn: conn, account: account} do
    assert {_res_conn, nil} = run(APIAuthPlug.fetch(conn, @pow_config))

    assert {res_conn, ^account} = run(APIAuthPlug.create(conn, account, @pow_config))

    assert %{private: %{api_access_token: access_token, api_renewal_token: renewal_token}} =
             res_conn

    assert {_res_conn, nil} =
             run(APIAuthPlug.fetch(with_auth_header(conn, "invalid"), @pow_config))

    assert {_res_conn, ^account} =
             run(APIAuthPlug.fetch(with_auth_header(conn, access_token), @pow_config))

    assert {res_conn, ^account} =
             run(APIAuthPlug.renew(with_auth_header(conn, renewal_token), @pow_config))

    assert %{
             private: %{
               api_access_token: renewed_access_token,
               api_renewal_token: renewed_renewal_token
             }
           } = res_conn

    assert {_res_conn, nil} =
             run(APIAuthPlug.fetch(with_auth_header(conn, access_token), @pow_config))

    assert {_res_conn, nil} =
             run(APIAuthPlug.renew(with_auth_header(conn, renewal_token), @pow_config))

    assert {_res_conn, ^account} =
             run(APIAuthPlug.fetch(with_auth_header(conn, renewed_access_token), @pow_config))

    assert %Conn{} = run(APIAuthPlug.delete(with_auth_header(conn, "invalid"), @pow_config))

    assert {_res_conn, ^account} =
             run(APIAuthPlug.fetch(with_auth_header(conn, renewed_access_token), @pow_config))

    assert %Conn{} =
             run(APIAuthPlug.delete(with_auth_header(conn, renewed_access_token), @pow_config))

    assert {_res_conn, nil} =
             run(APIAuthPlug.fetch(with_auth_header(conn, renewed_access_token), @pow_config))

    assert {_res_conn, nil} =
             run(APIAuthPlug.renew(with_auth_header(conn, renewed_renewal_token), @pow_config))
  end

  defp run({conn, value}), do: {run(conn), value}
  defp run(conn), do: Conn.send_resp(conn, 200, "")

  defp with_auth_header(conn, token), do: Plug.Conn.put_req_header(conn, "authorization", token)
end
