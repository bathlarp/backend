defmodule BathLARPWeb.V1.PronounsJSON do
  @moduledoc """
  Provides functions for rendering Pronouns entities to JSON.
  """
  alias BathLARP.SiteConfiguration.Pronouns
  alias BathLARPWeb.V1.Schemas.Pronouns.PronounsResource

  @doc """
  Renders a list of pronoun sets.
  """
  @spec index(%{:pronouns => list(Pronouns.t()), optional(any()) => any()}) :: %{
          data: list(PronounsResource.t())
        }
  def index(%{pronouns: pronouns}) do
    %{data: for(pronouns <- pronouns, do: data(pronouns))}
  end

  @doc """
  Renders a single pronoun set.
  """
  @spec show(%{:pronouns => Pronouns.t(), optional(any()) => any()}) :: %{
          data: PronounsResource.t()
        }
  def show(%{pronouns: pronouns}) do
    %{data: data(pronouns)}
  end

  defp data(%Pronouns{} = pronouns) do
    %PronounsResource{
      id: pronouns.id,
      type: "pronouns",
      attributes: %{
        subjective_personal: pronouns.subjective_personal,
        objective_personal: pronouns.objective_personal,
        possessive: pronouns.possessive,
        possessive_determiner: pronouns.possessive_determiner,
        reflexive: pronouns.reflexive
      }
    }
  end
end
