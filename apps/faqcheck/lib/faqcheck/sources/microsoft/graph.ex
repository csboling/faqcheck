defmodule Faqcheck.Sources.Microsoft.Graph.Drive do
  @derive [Poison.Encoder]
  defstruct [:id, :name, :description]
end
