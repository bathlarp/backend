defmodule BathLARPWeb.V1.PingController do
  @moduledoc """
  A simple controller to check that authentication is working correctly.
  """
  use BathLARPWeb, :controller

  def show(conn, _opts) do
    json(conn, %{
      "data" => %{
        ping: "pong"
      }
    })
  end
end
