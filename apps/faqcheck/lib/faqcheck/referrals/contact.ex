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
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Enum.map(fn item ->
      struct %Faqcheck.Referrals.Contact{}, %{field => item}
    end)
  end
end
