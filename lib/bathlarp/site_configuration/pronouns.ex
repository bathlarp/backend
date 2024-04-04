defmodule BathLARP.SiteConfiguration.Pronouns do
  @moduledoc """
  Repository model representing a set of pronouns.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pronouns" do
    field :subjective_personal, :string
    field :objective_personal, :string
    field :possessive, :string
    field :possessive_determiner, :string
    field :reflexive, :string

    timestamps()
  end

  @type t :: %__MODULE__{
          id: binary(),
          subjective_personal: binary(),
          objective_personal: binary(),
          possessive: binary(),
          possessive_determiner: binary(),
          reflexive: binary(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(pronouns, attrs) do
    pronouns
    |> cast(attrs, [
      :subjective_personal,
      :objective_personal,
      :possessive,
      :possessive_determiner,
      :reflexive
    ])
    |> validate_required([
      :subjective_personal,
      :objective_personal,
      :possessive,
      :possessive_determiner,
      :reflexive
    ])
  end
end
