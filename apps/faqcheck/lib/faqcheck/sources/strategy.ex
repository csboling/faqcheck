defmodule Faqcheck.Sources.Strategy do
  @callback to_changesets(String.t) :: {:ok, [Ecto.Changeset.t]}
end
