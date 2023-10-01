defmodule BathLARP.Accounts.Account do
  @moduledoc """
  Repository model representing an account on the BathLARP website. Note that
  this does not include information about the human who owns the account; that
  will be covered by the LARPer model.
  """
  use Ecto.Schema
  use Pow.Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    pow_user_fields()

    timestamps()
  end
end
