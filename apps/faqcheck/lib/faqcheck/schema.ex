defmodule Faqcheck.Schema do
  @doc """
  Adds schema relationships for the model's version history.
  """
  defmacro schema_versions() do
    item_type = __CALLER__.module |> Module.split() |> List.last()
    quote do
      has_many :versions, PaperTrail.Version,
        foreign_key: :item_id, where: [item_type: unquote(item_type)],
        preload_order: [desc: :inserted_at]
    end
  end
end
