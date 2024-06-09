defmodule BathLARPWeb.V1.PronounsController do
  use BathLARPWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias BathLARPWeb.V1.Schemas.Pronouns.ListPronounsResponse
  alias BathLARP.SiteConfiguration

  action_fallback BathLARPWeb.FallbackController

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["pronouns"]

  operation :index,
    operation_id: "listPronouns",
    summary: "List pronouns",
    description: "List the pronoun sets currently supported by the BathLARP site.",
    responses: %{
      ok: {"List pronouns response", "application/vnd.api+json", ListPronounsResponse},
      internal_server_error: OpenApiSpex.JsonErrorResponse.response()
    }

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    pronouns = SiteConfiguration.list_pronouns()
    render(conn, "index.json", pronouns: pronouns)
  end
end
