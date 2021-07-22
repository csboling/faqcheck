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

  def get_or_create_facility(name) do
    found = Repo.one from fac in Facility,
      where: fac.name == ^name,
      preload: [:address, :contacts, :hours, :keywords, :organization],
      limit: 1
    case found do
      nil -> %Facility{}
      facility -> facility
    end
  end

  def facility_history(id) do
    Repo.one from fac in Facility,
      where: fac.id == ^id,
      left_join: addr in assoc(fac, :address),
      left_join: org in assoc(fac, :organization),
      preload: [versions: :user,
		address: {addr, [versions: :user]},
		organization: {org, [versions: :user]}]
  end

  def upsert_facility(changeset) do
    case Ecto.get_meta(changeset.data, :state) do
      :loaded -> Repo.update!(%{changeset | action: :update})
      :built -> Repo.insert!(%{changeset | action: :insert})
    end
  end

  def upsert_facility(facility, params) do
    keywords = get_keywords(facility, params)
    changeset = facility
    |> Facility.changeset(params)
    |> Ecto.Changeset.put_assoc(:keywords, keywords)

    case Ecto.get_meta(facility, :state) do
      :loaded -> Repo.update!(changeset)
      :built -> Repo.insert!(changeset)
    end
  end

  def delete_facility(id) do
    Repo.delete!(%Facility{id: id})
  end

  def get_keywords(facility, params) do
    case params["keywords"] do
      nil -> Repo.all(from t in Tag, where: t.facility_id == ^facility.id)
      kws ->
        requested = kws
        |> Enum.map(fn {_, v} -> v["keyword"] end)
        existing_kws = Repo.all(from t in Tag, where: t.keyword in ^requested)
        existing_names = existing_kws
        |> Enum.map(fn kw -> kw.keyword end)
        |> MapSet.new()
        new_kws = MapSet.difference(requested |> MapSet.new(), existing_names)
        |> Enum.map(fn kw -> %Tag{keyword: kw} end)
        existing_kws ++ new_kws
    end
  end

  def get_facility_feedback(id) do
    Repo.one! from fac in Facility,
      where: fac.id == ^id,
      preload: [:feedback]
  end

  def leave_feedback(facility) do
    %Feedback{facility: facility}
    |> Feedback.changeset(%{})
  end

  def save_feedback(facility_id, params) do
    %Feedback{facility_id: facility_id}
    |> Feedback.changeset(params)
    |> Repo.insert()
  end
end
