defmodule Faqcheck.Sources.Microsoft.Http do
  use HTTPoison.Base

  @endpoint "https://graph.microsoft.com/v1.0"

  def process_request_url(url) do
    @endpoint <> url
  end

  def process_request_headers([token]) do
    ["Authorization": "Bearer #{token}"]
  end

  def process_request_headers([token, content_type]) do
    ["Authorization": "Bearer #{token}", "Content-Type": content_type]
  end
end
