defmodule BathLARP.SiteConfiguration do
  @moduledoc """
  The SiteConfiguration context.
  """

  import Ecto.Query, warn: false
  alias BathLARP.Repo

  alias BathLARP.SiteConfiguration.Pronouns

  @doc """
  Returns the list of pronouns.

  ## Examples

      iex> list_pronouns()
      [%Pronouns{}, ...]

  """
  @spec list_pronouns() :: list(Pronouns.t())
  def list_pronouns do
    Repo.all(Pronouns)
  end

  @doc """
  Gets a single pronouns.

  Raises `Ecto.NoResultsError` if the Pronouns does not exist.

  ## Examples

      iex> get_pronouns!(123)
      %Pronouns{}

      iex> get_pronouns!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_pronouns!(binary()) :: Pronouns.t()
  def get_pronouns!(id), do: Repo.get!(Pronouns, id)

  @doc """
  Creates a pronouns.

  ## Examples

      iex> create_pronouns(%{field: value})
      {:ok, %Pronouns{}}

      iex> create_pronouns(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_pronouns(map()) :: {:ok, Pronouns.t()} | {:error, Ecto.Changeset.t()}
  def create_pronouns(attrs \\ %{}) do
    %Pronouns{}
    |> Pronouns.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pronouns.

  ## Examples

      iex> update_pronouns(pronouns, %{field: new_value})
      {:ok, %Pronouns{}}

      iex> update_pronouns(pronouns, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_pronouns(Pronouns.t(), map()) :: {:ok, Pronouns.t()} | {:error, Ecto.Changeset.t()}
  def update_pronouns(%Pronouns{} = pronouns, attrs) do
    pronouns
    |> Pronouns.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pronouns.

  ## Examples

      iex> delete_pronouns(pronouns)
      {:ok, %Pronouns{}}

      iex> delete_pronouns(pronouns)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_pronouns(Pronouns.t()) :: {:ok, Pronouns.t()} | {:error, Ecto.Changeset.t()}
  def delete_pronouns(%Pronouns{} = pronouns) do
    Repo.delete(pronouns)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pronouns changes.

  ## Examples

      iex> change_pronouns(pronouns)
      %Ecto.Changeset{data: %Pronouns{}}

  """
  @spec change_pronouns(Pronouns.t(), map()) :: Ecto.Changeset.t()
  def change_pronouns(%Pronouns{} = pronouns, attrs \\ %{}) do
    Pronouns.changeset(pronouns, attrs)
  end
end
