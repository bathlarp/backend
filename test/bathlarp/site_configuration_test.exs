defmodule BathLARP.SiteConfigurationTest do
  use BathLARP.DataCase

  alias BathLARP.SiteConfiguration

  describe "pronouns" do
    alias BathLARP.SiteConfiguration.Pronouns

    import BathLARP.SiteConfigurationFixtures

    @invalid_attrs %{
      subjective_personal: nil,
      objective_personal: nil,
      possessive: nil,
      possessive_determiner: nil,
      reflexive: nil
    }

    test "list_pronouns/0 returns all pronouns" do
      pronouns = pronouns_fixture()
      assert SiteConfiguration.list_pronouns() == [pronouns]
    end

    test "get_pronouns!/1 returns the pronouns with given id" do
      pronouns = pronouns_fixture()
      assert SiteConfiguration.get_pronouns!(pronouns.id) == pronouns
    end

    test "create_pronouns/1 with valid data creates a pronouns" do
      valid_attrs = %{
        subjective_personal: "some subjective_personal",
        objective_personal: "some objective_personal",
        possessive: "some possessive",
        possessive_determiner: "some possessive_determiner",
        reflexive: "some reflexive"
      }

      assert {:ok, %Pronouns{} = pronouns} = SiteConfiguration.create_pronouns(valid_attrs)
      assert pronouns.subjective_personal == "some subjective_personal"
      assert pronouns.objective_personal == "some objective_personal"
      assert pronouns.possessive == "some possessive"
      assert pronouns.possessive_determiner == "some possessive_determiner"
      assert pronouns.reflexive == "some reflexive"
    end

    test "create_pronouns/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SiteConfiguration.create_pronouns(@invalid_attrs)
    end

    test "update_pronouns/2 with valid data updates the pronouns" do
      pronouns = pronouns_fixture()

      update_attrs = %{
        subjective_personal: "some updated subjective_personal",
        objective_personal: "some updated objective_personal",
        possessive: "some updated possessive",
        possessive_determiner: "some updated possessive_determiner",
        reflexive: "some updated reflexive"
      }

      assert {:ok, %Pronouns{} = pronouns} =
               SiteConfiguration.update_pronouns(pronouns, update_attrs)

      assert pronouns.subjective_personal == "some updated subjective_personal"
      assert pronouns.objective_personal == "some updated objective_personal"
      assert pronouns.possessive == "some updated possessive"
      assert pronouns.possessive_determiner == "some updated possessive_determiner"
      assert pronouns.reflexive == "some updated reflexive"
    end

    test "update_pronouns/2 with invalid data returns error changeset" do
      pronouns = pronouns_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SiteConfiguration.update_pronouns(pronouns, @invalid_attrs)

      assert pronouns == SiteConfiguration.get_pronouns!(pronouns.id)
    end

    test "delete_pronouns/1 deletes the pronouns" do
      pronouns = pronouns_fixture()
      assert {:ok, %Pronouns{}} = SiteConfiguration.delete_pronouns(pronouns)
      assert_raise Ecto.NoResultsError, fn -> SiteConfiguration.get_pronouns!(pronouns.id) end
    end

    test "change_pronouns/1 returns a pronouns changeset" do
      pronouns = pronouns_fixture()
      assert %Ecto.Changeset{} = SiteConfiguration.change_pronouns(pronouns)
    end
  end
end
