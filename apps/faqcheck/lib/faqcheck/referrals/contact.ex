defmodule Faqcheck.Referrals.Contact do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "contacts" do
    field :name,  :string
    field :phone, :string
    field :email, :string

    timestamps()
  end

  def split(str, field) do
    str
    |> String.split(";")
    |> Enum.map(fn item ->
      struct %Faqcheck.Referrals.Contact{}, %{field => String.trim(item)}
    end)
  end
end
