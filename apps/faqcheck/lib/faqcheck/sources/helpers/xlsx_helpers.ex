defmodule Faqcheck.Sources.XlsxHelpers do
  def map_xlsx(filename, row_func) do
    Enum.flat_map(
      Xlsxir.multi_extract(filename),
      fn {:ok, sheet_id} ->
	info = Xlsxir.get_info(sheet_id)
        mda = Xlsxir.get_mda(sheet_id)
        rows = Keyword.get(info, :rows)
        results = Enum.map(1..rows-1, &row_func.(mda[&1]))
        Xlsxir.close(sheet_id)
	results
      end)
  end
end
