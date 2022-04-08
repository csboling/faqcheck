defmodule FaqcheckWeb.MicrosoftTeamsController do
  use FaqcheckWeb, :controller

  alias ExMicrosoftBot.Models.Activity
  alias ExMicrosoftBot.Models.Attachment
  alias ExMicrosoftBot.Client.Conversations
  alias Faqcheck.Referrals

  def message(conn, params) do
    with {:ok, activity} <- Activity.parse(params) do
      [locale | _] = String.split(params["locale"], "-")

      limit = 20

      {message, card_body} = process_message(conn, locale, activity.text, limit)

      resp_activity = %Activity{
	type: "message",
	conversation: activity.conversation,
	recipient: activity.from,
	from: activity.recipient,
	replyToId: activity.id,
	text: message,
	attachments: card_body && [
	  %Attachment{
	    name: "results",
	    contentType: "application/vnd.microsoft.card.adaptive",
	    content: %{
	      "type" => "AdaptiveCard",
	      "msTeams" => %{
		"width" => "full",
	      },
	      "version" => "1.0",
	      "body" => card_body,
            },
          },
        ],
      }

      Conversations.reply_to_activity(
	activity.serviceUrl,
	activity.conversation.id,
	activity.id,
	resp_activity)

      send_resp(conn, 200, "{}")
    else
      _ ->
	send_resp(conn, 400, "{}")
    end
  end

  def process_message(conn, locale, text, limit) do
    if String.downcase(String.trim(text)) == "help" do
      show_help(conn, locale, text)
    else
      search_results(conn, locale, text, limit)
    end
  end

  def show_help(conn, locale, text) do
    origin = FaqcheckWeb.Router.Helpers.url(conn)
    message = """
This is a chat bot interface to FaqCheck, which you can use on the web at [#{origin}](#{origin}).
- Sending the message text "help" to this bot will display this help message.
- Sending any other message text to the bot will search the FaqCheck database for agencies with matching names or descriptions, and reply with a table of results.
- To filter your search you can use search terms like "open:Monday" or "in:Albuquerque" alongside other terms. If the location filter has a space in it, replace it with "+".

Example searches:
- food
- food box open:today
- shelter in:Las+Cruces open:Friday
"""

    {message, nil}
  end

  def search_results(conn, locale, text, limit) do
    search = parse_message(text)
    facilities = Referrals.list_facilities(search, limit: limit, include_total_count: true)
    origin = FaqcheckWeb.Router.Helpers.url(conn)
    results_link = origin <> FaqcheckWeb.Router.Helpers.live_path(conn, FaqcheckWeb.FacilitiesLive, "en", search: search)
    message = "Here are the first #{limit} results out of #{facilities.metadata.total_count} total for your search \"#{text}\". Click [here](#{results_link}) to see all search results. You can include filters like 'open:today' / 'open:monday' or 'in:87111' to narrow down your search."

    card_body = [
      %{
        "type" => "ColumnSet",
        "columns" => [
          column(
            facilities.entries,
            "Name",
            fn f ->
      	path = FaqcheckWeb.Router.Helpers.facility_path conn,
      	  :show, locale, f
              "[#{f.name}](#{origin <> path})"
            end),
          column(
            facilities.entries,
            "Address",
            fn f -> f.address.street_address end),
          column(
            facilities.entries,
            "Keywords",
            fn f ->
      	f.keywords
      	|> Enum.map(fn k -> k.keyword end)
      	|> Enum.join(", ")
            end),
        ],
      }
    ]

    {message, card_body}
  end

  def column(rows, title, fetch) do
    %{
      "type" => "Column",
      "items" => [
        %{
          "type" => "TextBlock",
	  "weight" => "bolder",
	  "text" => title,
        } | Enum.map(rows, fn r ->
	  %{
            "type" => "TextBlock",
	    "separator" => true,
	    "text" => fetch.(r),
          }
        end)
      ]
    }
  end

  @doc """
  Parse search filters from a chat message.

  ## Examples

    iex> parse_message("example with no directives")
    %{"name" => "example with no directives"}

    iex> parse_message("something open:today")
    %{"name" => "something", "weekday" => Faqcheck.Referrals.OperatingHours.Weekday.Today.value}

    iex> parse_message("something else open:sun in:12345")
    %{
      "name" => "something else",
      "weekday" => Faqcheck.Referrals.OperatingHours.Weekday.Sunday.value,
      "zipcode" => "12345"
    }
  """
  def parse_message(text) do
    {directives, words} = text
    |> String.split()
    |> Enum.split_with(fn word -> String.contains?(word, ":") end)

    directives
    |> Enum.reduce(
      %{"name" => Enum.join(words, " ")},
      fn directive, acc ->
        [dir, arg] = String.split(directive, ":", parts: 2)
    	case dir do
    	  "open" ->
    	    Map.put(
    	      acc,
    	      "weekday",
    	      Faqcheck.Referrals.OperatingHours.parse_day(arg).value)
    	  "in" ->
            Map.put(
    	      acc,
    	      "zipcode",
    	      arg
              |> String.split("+")
              |> Enum.join(" "))
    	  _ ->
    	    acc
    	end
      end)
  end
end
