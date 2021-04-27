defmodule Faqcheck.Sources.Microsoft.API do
  alias Faqcheck.Sources.Microsoft.Graph
  alias Faqcheck.Sources.Microsoft.Http

  def list_drive(token) do
    with {:ok, %HTTPoison.Response{body: body}} <- Http.get("/drives", [token]),
         {:ok, %{"value" => drives}} <- Poison.decode(body, as: %{"value" => [%Graph.Drive{}]}) do
      drives
    else
      _ -> []
    end
  end
end
