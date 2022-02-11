defmodule Faqcheck.Referrals.Keyword do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "keywords" do
    field :keyword, :string
  end

  def changeset(kw, attrs) do
    kw
    |> cast(attrs, [:keyword])
    |> unique_constraint(:keyword)
  end

  def split(kws) do
    kws
    |> String.split(";", trim: true)
    |> Enum.map(fn word -> %{keyword: String.trim(word)} end)
  end
end
