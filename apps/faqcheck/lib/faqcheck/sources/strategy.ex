defmodule Faqcheck.Sources.Strategy do
  @callback id() :: String.t

  @callback description() :: String.t

  @callback to_changesets(Map.t, Map.t) :: list(Ecto.Changeset.t)
end
