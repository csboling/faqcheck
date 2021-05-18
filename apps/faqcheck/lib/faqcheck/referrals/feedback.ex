defmodule Faqcheck.Referrals.Feedback do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  schema "facility_feedback" do
    field :helpful, :boolean
    field :accurate, :boolean
    field :address_correct, :boolean
    field :phone_correct, :boolean
    field :description_accurate, :boolean
    field :client_comments, :string
    field :client_email, :string
    field :client_phone, :string

    timestamps()

    belongs_to :facility, Faqcheck.Referrals.Facility.Facility
  end

  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:client_comments, :client_email, :client_phone])
  end
end
