defmodule Faqcheck.Sources.Microsoft.Graph do
  defmodule Entry do
    @derive [Poison.Encoder]
    defstruct [
      :id,
      :name,
      :description,
      :displayName,
      :error,

      :driveType,
      :file,
      :fileSystemInfo,
      :folder,
      :siteCollection,
    ]
  end
end
