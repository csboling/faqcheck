defmodule Faqcheck.Sources.ApiAuth do
  @doc """
  Additional parameters to include in the access token request.
  """
  @callback auth_params() :: map()

  @doc """
  Scopes that must be present in the access token. If these scopes aren't present, the user will be warned about an API misconfiguration.
  """
  @callback requirements(map(), map()) :: {:ok, map()} | {:error, String.t}
end
