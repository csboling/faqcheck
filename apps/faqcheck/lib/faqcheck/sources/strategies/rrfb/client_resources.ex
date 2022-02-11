defmodule Faqcheck.Sources.Strategies.RRFB.ClientResources do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.Contact
  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Referrals.Keyword, as: Tag
  alias Faqcheck.Sources
  alias Faqcheck.Sources.Microsoft.API
  alias Faqcheck.Sources.Microsoft.Graph
  alias Faqcheck.Sources.StringHelpers

  @impl Sources.Strategy
  def id(), do: "rrfb_client_resources"

  @impl Sources.Strategy
  def description(), do: "Import Roadrunner Food Bank .xlsx Client Resources spreadsheet stored in SharePoint"

  @impl Sources.Strategy
  def provider(), do: "microsoft"

  @impl Sources.Strategy
  def build_scrape_params(schedule) do
    schedule.params
  end

  @impl Sources.Strategy
  def build_scrape_session() do
    token_params = %{
      grant_type: "client_credentials",
      scope: "https://graph.microsoft.com/.default"
    }
    with {:ok, %{"access_token" => token}} <- OpenIDConnect.fetch_tokens(:microsoft, token_params) do
      {:ok, %{"microsoft" => token}}
    else
      error -> error
    end
  end

  @impl Sources.Strategy
  def prepare_feed(
    params = %{"drive_id" => drive_id, "entry_id" => entry_id},
    %{"microsoft" => token}) do
    with {:ok, entry} <- API.Sharepoint.get_item(token, drive_id, entry_id),
         {:ok, worksheets} <- API.Excel.list_worksheets(token, drive_id, entry_id) do
      {:ok, %Sources.Feed{
        name: entry.name,
        pages: worksheets,
	params: params,
      }}
    else
      error -> error
    end
  end

  @impl Sources.Strategy
  def to_changesets(
    %Sources.Feed{
      params: %{"drive_id" => drive_id, "entry_id" => entry_id},
      session: %{"microsoft" => token},
    },
    %Graph.Worksheet{id: worksheet_id, name: category}) do
    case API.Excel.used_range token,
      drive_id, entry_id, worksheet_id do
      {:ok, %{"values" => values}} when is_nil(values) ->
        {:ok, []}
      {:ok, %{"values" => values}} ->
        {:ok,
	 values
         |> filter_rows()
         |> Enum.map(&row_to_changeset/1)}
      {:error, {type, message}} ->
	{:error, "couldn't load sheet '#{category}' from the Microsoft API: #{message} (#{type})"}
    end
  end

  def filter_rows(rows) do
    rows
    |> Stream.drop(2)
    |> Stream.filter(fn row ->
      String.trim(Enum.at(row, 0)) == "" && String.trim(Enum.at(row, 1)) != ""
    end)
  end

  def row_to_changeset(row) do
    name = Enum.at(row, 1)
    Referrals.get_or_create_facility(name)
    |> Facility.changeset(%{})
    |> Sources.try_process(:name, name)
    |> Sources.try_process_collection(
      :contacts,
      [
        Enum.at(row, 3),
        Enum.at(row, 4),
        Enum.at(row, 5),
      ],
      fn [phone, email, website] ->
        Enum.concat([
          Contact.split(phone, :phone),
          Contact.split(email, :email),
          Contact.split(website, :website),
        ])
      end,
      [:name, :phone, :email, :website])
    |> Sources.try_process_collection(
      :hours,
      Enum.at(row, 6),
      &StringHelpers.parse_hours/1,
      [:weekday, :opens, :closes, :always_open, :week_regularity])
    |> Sources.try_process(:address, %{street_address: Enum.at(row, 7)})
    |> Sources.try_process(:description, Enum.at(row, 8))
    |> Facility.changeset(%{})
    |> Ecto.Changeset.put_assoc(
       :keywords,
       Facility.parse_keywords(%{keywords: Tag.split(Enum.at(row, 2))}))
  end
end
