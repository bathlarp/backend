defmodule BathLARPWeb.ApiSpec do
  @moduledoc """
  Global definitions for OpenAPI spec generation.
  """

  alias OpenApiSpex.{Components, Info, OpenApi, Paths, SecurityScheme}
  alias BathLARPWeb.Router
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [%OpenApiSpex.Server{url: "https://api.bathlarp.co.uk"}],
      info: %Info{
        title: to_string(Application.spec(:bathlarp, :description)),
        version: to_string(Application.spec(:bathlarp, :vsn))
      },
      paths: Paths.from_router(Router),
      components: %Components{
        securitySchemes: %{
          "authorization" => %SecurityScheme{type: "http", scheme: "bearer"}
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
