defmodule BathLARPWeb.V1.Schemas.Session do
  @moduledoc """
  Definitions of OpenAPI components relating to user sessions.
  """
  alias OpenApiSpex.Schema

  defmodule CreateSessionAttributes do
    @moduledoc """
    OpenAPI component describing the attributes of a Create Session request.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateSessionAttributes",
      description: "Attributes for creating a session",
      type: :object,
      properties: %{
        email: %Schema{
          type: :string,
          description: "E-mail address",
          format: :email,
          pattern:
            "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        },
        password: %Schema{type: :string, description: "Password"}
      },
      required: [:email, :password]
    })
  end

  defmodule CreateSessionRequest do
    @moduledoc """
    OpenAPI component describing the structure of a Create Session request.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateSessionRequest",
      description: "POST request for creating a session",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{type: :string, description: "Resource type", enum: ["session"]},
            attributes: CreateSessionAttributes
          },
          required: [:type, :attributes]
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "type" => "session",
          "attributes" => %{
            "email" => "test@example.com",
            "password" => "supersecret"
          }
        }
      }
    })
  end

  defmodule UpdateSessionRequest do
    @moduledoc """
    OpenAPI component describing the structure of an Update Session request.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "UpdateSessionRequest",
      description: "PATCH request for updating a session",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{type: :string, description: "Resource type", enum: ["session"]},
            id: %Schema{type: :string, format: :uuid}
          },
          required: [:type, :id]
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "type" => "session",
          "id" => "df54c235-d8bf-431f-9525-f91484935252"
        }
      }
    })
  end

  defmodule SessionAttributes do
    @moduledoc """
    OpenAPI component describing the attributes of a Session resource.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "SessionAttributes",
      description: "Session tokens",
      type: :object,
      properties: %{
        access_token: %Schema{
          type: :string,
          description: "Short-lived token for regular API access"
        },
        renewal_token: %Schema{
          type: :string,
          description: "Long-lived token for refreshing the access token"
        }
      },
      required: [:access_token, :renewal_token]
    })
  end

  defmodule CreateSessionResponse do
    @moduledoc """
    OpenAPI component describing the structure of a Create Session response.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateSessionResponse",
      description: "Success response to a Create Session request",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{type: :string, description: "Resource type", enum: ["session"]},
            id: %Schema{type: :string, description: "Session ID", format: :uuid},
            attributes: SessionAttributes
          },
          required: [:type, :id, :attributes]
        }
      }
    })
  end

  defmodule UpdateSessionResponse do
    @moduledoc """
    OpenAPI component describing the structure of an Update Session response.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "UpdateSessionResponse",
      description: "Success response to an Update Session request",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{type: :string, description: "Resource type", enum: ["session"]},
            id: %Schema{type: :string, description: "Session ID", format: :uuid},
            attributes: SessionAttributes
          },
          required: [:type, :id, :attributes]
        }
      }
    })
  end
end
