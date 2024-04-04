defmodule BathLARP.Repo.Migrations.CreatePronouns do
  use Ecto.Migration

  def change do
    create table(:pronouns, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :subjective_personal, :string
      add :objective_personal, :string
      add :possessive, :string
      add :possessive_determiner, :string
      add :reflexive, :string

      timestamps()
    end
  end
end
