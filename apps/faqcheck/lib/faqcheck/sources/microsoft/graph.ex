defmodule Faqcheck.Sources.Microsoft.Graph do
  defmodule Entry do
    @derive [Poison.Encoder]
    defstruct [
      :type,

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

  defmodule Worksheet do
    @derive [Poison.Encoder]
    defstruct [
      :id,
      :name,
      :position,
      :visibility,
    ]
  end

  defmodule Table do
    @derive [Poison.Encoder]
    defstruct [
      :id,
      :name,
    ]
  end
end
