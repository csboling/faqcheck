defmodule Faqcheck.Sources.Microsoft.Graph do
  defmodule Entry do
    @derive [Poison.Encoder]
    defstruct [:id, :name, :description, :file, :fileSystemInfo, :folder]
  end
end
