defmodule Faqcheck.Referrals.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  schema "keywords" do
    field :keyword, :string
  end

  def changeset(kw, attrs) do
    kw
    |> cast(attrs, [:keyword])
  end

  def split(kws) do
    kws
    |> String.split(";")
    |> Enum.map(fn word -> %{keyword: String.trim(word)} end)
  end
end
