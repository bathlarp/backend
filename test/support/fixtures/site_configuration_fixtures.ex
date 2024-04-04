defmodule BathLARP.SiteConfigurationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BathLARP.SiteConfiguration` context.
  """

  @doc """
  Generate a pronoun set.
  """
  def pronouns_fixture(attrs \\ %{}) do
    {:ok, pronouns} =
      attrs
      |> Enum.into(%{
        subjective_personal: "I",
        objective_personal: "me",
        possessive: "mine",
        possessive_determiner: "my",
        reflexive: "myself"
      })
      |> BathLARP.SiteConfiguration.create_pronouns()

    pronouns
  end
end
