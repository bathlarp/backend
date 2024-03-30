defmodule BathLARPWeb.V1.Schemas.Account do
  @moduledoc """
  Definitions of OpenAPI components relating to user accounts.
  """

  alias OpenApiSpex.Schema

  defmodule CreateAccountAttributes do
    @moduledoc """
    OpenAPI component describing the attributes of an Account resource.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateAccountAttributes",
      description: "Attributes for creating an account",
      type: :object,
      properties: %{
        email: %Schema{
          type: :string,
          description: "E-mail address",
          format: :email,
          pattern:
            "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        },
        password: %Schema{type: :string, description: "Password", minLength: 8}
      },
      required: [:email, :password]
    })
  end

  defmodule CreateAccountRequest do
    @moduledoc """
    OpenAPI component describing the structure of a Create Account request.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateAccountRequest",
      description: "POST body to create an account with BathLARP",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{type: :string, description: "Resource type", enum: ["account"]},
            attributes: CreateAccountAttributes
          },
          required: [:type, :attributes]
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "type" => "account",
          "attributes" => %{
            "email" => "test@example.com",
            "password" => "password123"
          }
        }
      }
    })
  end

  defmodule CreateAccountResponse do
    @moduledoc """
    OpenAPI component describing the structure of a Create Account response.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateAccountResponse",
      description: "Response schema for creating an account",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{
              type: :string,
              description: "Resource type",
              enum: ["account-creation-request"]
            },
            id: %Schema{
              type: :string,
              format: :uuid,
              description: "ID of the account creation request"
            },
            attributes: %Schema{
              type: :object,
              properties: %{
                next_step: %Schema{type: :string, description: "What happens next"}
              },
              required: [:next_step]
            }
          },
          required: [:id, :type, :attributes]
        }
      }
    })
  end
end
