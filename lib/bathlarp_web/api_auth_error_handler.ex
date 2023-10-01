defmodule BathLARPWeb.APIAuthErrorHandler do
  @moduledoc """
  Plug for handling authentication errors.
  """
  use BathLARPWeb, :controller
  alias Plug.Conn

  @spec call(Conn.t(), :not_authenticated) :: Conn.t()
  def call(conn, :not_authenticated) do
    conn
    |> put_status(401)
    |> json(%{error: %{status: 401, message: "Not authenticated"}})
  end
end
