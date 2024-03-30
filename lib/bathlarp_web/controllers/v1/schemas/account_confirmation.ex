defmodule BathLARPWeb.V1.Schemas.AccountConfirmation do
  @moduledoc """
  Definitions of OpenAPI components relating to confirmation of user accounts.
  """

  alias OpenApiSpex.Schema

  defmodule CreateAccountConfirmationAttributes do
    @moduledoc """
    OpenAPI component describing the attributes of an Account Confirmation resource.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateAccountConfirmationAttributes",
      description: "Attributes for confirming an account",
      type: :object,
      properties: %{
        token: %Schema{
          type: :string,
          description: "Code sent to the e-mail address supplied during account creation"
        }
      },
      required: [:token]
    })
  end

  defmodule CreateAccountConfirmationRequest do
    @moduledoc """
    OpenAPI component describing the structure of an Account Confirmation request.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateAccountConfirmationRequest",
      description: "POST body to confirm an account with BathLARP",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{
              type: :string,
              description: "Resource type",
              enum: ["account-confirmation"]
            },
            attributes: CreateAccountConfirmationAttributes
          },
          required: [:type, :attributes]
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "type" => "account-confirmation",
          "attributes" => %{
            "token" => "secretcode"
          }
        }
      }
    })
  end

  defmodule CreateAccountConfirmationResponse do
    @moduledoc """
    OpenAPI component describing the structure of an Account Confirmation response.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateAccountConfirmationResponse",
      description: "Body of a success response to a request to confirm an account with BathLARP",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{
              type: :string,
              description: "Resource type",
              enum: ["account-confirmation"]
            },
            id: %Schema{
              type: :string,
              description: "ID of the successful confirmation."
            }
          },
          required: [:type, :id]
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "type" => "account-confirmation",
          "id" => "df54c235-d8bf-431f-9525-f91484935252"
        }
      }
    })
  end
end
