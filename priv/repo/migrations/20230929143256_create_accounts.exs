defmodule BathLARP.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:accounts, [:email])
  end
end
