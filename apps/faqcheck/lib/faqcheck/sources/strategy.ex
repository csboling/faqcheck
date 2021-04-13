defmodule Faqcheck.Sources.Strategy do
  @callback to_changesets(String.t) :: list(Ecto.Changeset.t)
end
