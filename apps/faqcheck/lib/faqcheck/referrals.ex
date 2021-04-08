defmodule Faqcheck.Referrals do
  @moduledoc """
  The Referrals context.
  """

  import Ecto.Query, warn: false
  alias Faqcheck.Repo
  alias Faqcheck.Referrals.Organization

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all from o in Organization,
      preload: [facilities: [:address, contacts: :hours]]
  end

  @doc """
  Gets a single organization.

  Raises if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

  """
  def get_organization!(id) do
    Repo.one! from org in Organization,
      where: org.id == ^id,
      preload: [facilities: :address]
  end

  def organization_history(id) do
    Repo.one from org in Organization,
      where: org.id == ^id,
      preload: [versions: :user]
  end

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, ...}

  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, ...}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, ...}

  """
  def delete_organization(%Organization{} = organization) do
    organization
    |> Repo.delete()
  end

  @doc """
  Returns a data structure for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Todo{...}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end
end
