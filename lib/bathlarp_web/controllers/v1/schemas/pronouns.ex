defmodule BathLARPWeb.V1.Schemas.Pronouns do
  @moduledoc """
  Definitions of OpenAPI components relating to pronoun sets.
  """

  alias OpenApiSpex.Schema

  defmodule PronounsAttributes do
    @moduledoc """
    OpenAPI component describing the attributes of a Pronoun Set resource.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "PronounstAttributes",
      description: "Attributes of a pronoun set",
      type: :object,
      properties: %{
        subjective_personal: %Schema{type: :string, example: "I"},
        objective_personal: %Schema{type: :string, example: "me"},
        possessive: %Schema{type: :string, example: "mine"},
        possessive_determiner: %Schema{type: :string, example: "my"},
        reflexive: %Schema{type: :string, example: "myself"}
      },
      required: [
        :subjective_personal,
        :objective_personal,
        :possessive,
        :possessive_determiner,
        :reflexive
      ]
    })
  end

  defmodule PronounsResource do
    @moduledoc """
    OpenAPI component describing the structure of a Pronouns resource.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "PronounsResource",
      description: "Data structure for a pronoun set",
      type: :object,
      properties: %{
        type: %Schema{
          type: :string,
          description: "Resource type",
          enum: ["pronouns"]
        },
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "ID of the pronoun set"
        },
        attributes: PronounsAttributes
      },
      required: [:id, :type, :attributes]
    })
  end

  defmodule ListPronounsResponse do
    @moduledoc """
    OpenAPI component describing the structure of a List Pronouns response.
    """
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ListPronounsResponse",
      description: "Response schema for listing pronoun sets",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: PronounsResource
        }
      }
    })
  end
end
