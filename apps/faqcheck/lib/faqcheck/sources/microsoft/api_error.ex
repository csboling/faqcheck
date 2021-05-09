defmodule Faqcheck.Sources.Microsoft.APIError do
  defexception message: "error calling Microsoft Graph API",
    url: "/",
    details: {}
end
