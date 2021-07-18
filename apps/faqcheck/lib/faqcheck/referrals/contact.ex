defmodule Faqcheck.Referrals.Contact do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Faqcheck.Schema

  import Ecto.Changeset

  schema "contacts" do
    field :name,  :string
    field :phone, :string
    field :email, :string
    field :website, :string

    timestamps()

    schema_versions()
  end

  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :phone, :email, :website])
    |> Faqcheck.Repo.versions()
  end

  def split(str, field) do
    str
    |> String.split(";")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Enum.map(fn item -> %{field => item} end)
  end
end
