defmodule Faqcheck.Sources.Microsoft.ApiAuth do
  @behaviour Faqcheck.Sources.ApiAuth

  @impl Faqcheck.Sources.ApiAuth
  def auth_params, do: %{
    prompt: "consent",
    resource: "https://graph.microsoft.com",
  }

  @required_scopes MapSet.new(~w(Files.Read.All Files.Read.All))

  @impl Faqcheck.Sources.ApiAuth
  def requirements(tokens, claims) do
    got_scopes = MapSet.new(String.split(tokens["scope"]))
    if !Enum.empty?(MapSet.intersection(@required_scopes, got_scopes)) do
      {:ok, claims}
    else
      {:error, "Microsoft did not authorize all required permissions. Received: #{Enum.join(got_scopes, ", ")}; expected one of: #{Enum.join(@required_scopes, ", ")}"}
    end
  end
end
