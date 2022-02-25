defmodule FaqcheckWeb.MicrosoftTeamsController do
  use FaqcheckWeb, :controller

  alias ExMicrosoftBot.Models.Activity
  alias ExMicrosoftBot.Models.Attachment
  alias ExMicrosoftBot.Client.Conversations
  alias Faqcheck.Referrals

  def message(conn, params) do
    with {:ok, activity} <- Activity.parse(params) do
      facilities = Referrals.list_facilities(
	parse_message(activity.text),
	limit: 50)
      message = "I found these facilities. You can include filters like 'open:today' / 'open:monday' or 'in:87111' to narrow down your search."

      [locale | _] = String.split(params["locale"], "-")
      origin = FaqcheckWeb.Router.Helpers.url(conn)
      resp_activity = %Activity{
	type: "message",
	conversation: activity.conversation,
	recipient: activity.from,
	from: activity.recipient,
	replyToId: activity.id,
	text: message,
	attachments: [
	  %Attachment{
	    name: "results",
	    contentType: "application/vnd.microsoft.card.adaptive",
	    content: %{
	      "type" => "AdaptiveCard",
	      "msTeams" => %{
		"width" => "full",
	      },
	      "version" => "1.0",

	      "body" => [
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
		},
	      ],
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
    	      arg)
    	  _ ->
    	    acc
    	end
      end)
  end
end
