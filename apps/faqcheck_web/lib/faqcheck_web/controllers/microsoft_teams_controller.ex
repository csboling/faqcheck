defmodule FaqcheckWeb.MicrosoftTeamsController do
  use FaqcheckWeb, :controller

  alias ExMicrosoftBot.Models.Activity
  alias ExMicrosoftBot.Models.Attachment
  alias ExMicrosoftBot.Client.Conversations
  alias Faqcheck.Referrals

  def message(conn, params) do
    with {:ok, activity} <- Activity.parse(params) do
      facilities = Referrals.list_facilities(
	%{ "name" => activity.text },
	limit: 10)
      message = "Found these facilities:"

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
end
