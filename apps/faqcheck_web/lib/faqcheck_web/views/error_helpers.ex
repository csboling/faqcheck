defmodule FaqcheckWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML
  require FaqcheckWeb.Gettext

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    name = input_name(form, field)
    form.errors
    |> Keyword.get_values(field)
    |> Enum.map(fn {msg, opts} ->
      data = Keyword.get(opts, :data)
      error = Keyword.get(opts, :error)
      stacktrace = Keyword.get(opts, :stacktrace)
      ~E"""
      <details class="invalid-feedback" phx-error-for="<%= field %>">
        <summary><%= name <> ": " <> FaqcheckWeb.Gettext.dgettext "errors", "input was not understood: %{input}", input: inspect(data) %></summary>
	<pre><%= Exception.format(:error, error, stacktrace) %></pre>
      </details>
      """
    end)
  end
end
