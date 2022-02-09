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
    # |> Enum.map(&find/1)
  end

  # def find(word) do
  #   case Faqcheck.Repo.one(from t in Faqcheck.Referrals.Keyword, where: t.keyword == ^word) do
  #     nil -> %{keyword: word}
  #     kw -> %{id: kw.id, keyword: word}
  #   end
  # end
end
