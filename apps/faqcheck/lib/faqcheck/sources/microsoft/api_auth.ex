defmodule Faqcheck.Sources.Microsoft.ApiAuth do
  @behaviour Faqcheck.Sources.ApiAuth

  @impl Faqcheck.Sources.ApiAuth
  def auth_params, do: %{resource: "https://graph.microsoft.com"}

  @required_scopes MapSet.new(~w(Sites.Read Files.Read))

  @impl Faqcheck.Sources.ApiAuth
  def requirements(tokens, claims) do
    got_scopes = MapSet.new(String.split(tokens["scope"]))
    if MapSet.subset?(@required_scopes, got_scopes) do
      {:ok, claims}
    else
      missing = MapSet.difference(got_scopes, @required_scopes)
      {:error, "Microsoft did not authorize all required permissions. Missing: #{Enum.join(missing, ", ")}"}
    end
  end
end
