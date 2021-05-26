defmodule Faqcheck.Referrals do
  @moduledoc """
  The Referrals context.
  """

  import Ecto.Query, warn: false
  alias Faqcheck.Repo
  alias Faqcheck.Referrals.Keyword, as: Tag
  alias Faqcheck.Referrals.Organization
  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Referrals.FacilityFilters
  alias Faqcheck.Referrals.Feedback

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

  def list_facilities(search \\ %{}, opts \\ []) do
    with {:ok, query, _values} <- Filterable.apply_filters(Facility, search, FacilityFilters, opts) do
      q = from f in query,
        order_by: [asc: f.id],
        preload: [:address, :contacts, :hours, :keywords, :organization]
      Repo.paginate(q, opts)
    end
  end

  def get_facility!(id) do
    Repo.one! from fac in Facility,
      where: fac.id == ^id,
      preload: [:address, :contacts, :hours, :keywords, :organization]
  end

  def upsert_facility(facility, params) do
    keywords = Repo.all(from t in Tag, where: t.keyword in ^params["keywords"])
    changeset = facility
    |> Facility.changeset(params)
    |> Ecto.Changeset.put_assoc(:keywords, keywords)
    if is_nil(changeset.data.id) do
      Repo.insert!(changeset)
    else
      Repo.update!(changeset)
    end
  end

  def facility_history(id) do
    Repo.one from fac in Facility,
      where: fac.id == ^id,
      preload: [versions: :user]
  end

  def leave_feedback(facility) do
    %Feedback{facility: facility}
    |> Feedback.changeset(%{})
  end

  # def find_keywords(kw_list) do
  #   keywords = kw_list
  #   |> String.split(';')
  #   |> Enum.map(&String.trim/1)
  #   |> MapSet.new()
  #   existing = Repo.all from k in Tag,
  #     where: k.name in ^keywords,
  #     order_by: k.name
  #   found = existing
  #   |> Enum.map(fn kw -> kw.name end)
  #   |> MapSet.new()
  #   new = MapSet.difference(keywords, found)
  #   |> Enum.map(fn name -> %Tag{keyword: name} end)

  #   [existing ++ new]
  #   |> Enum.sort_by(:name)
  # end
end
