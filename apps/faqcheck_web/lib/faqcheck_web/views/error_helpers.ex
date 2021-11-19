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

  def change_warning(form, field) do
    case form.source do
      %Ecto.Changeset{changes: changes} ->
	if Ecto.get_meta(form.source.data, :state) == :loaded do
	  change = changes[field]
	  if !is_nil(change) do
            ~E"""
	    <span class="alert-warning" phx-error-for="<%= field %>">
	      <%= FaqcheckWeb.Gettext.gettext "'%{field}' has changed", field: Atom.to_string(field) %>
	    </span>
	    """
	  else
	    []
	  end
	else
	  []
	end
      _ ->
	[]
    end
  end
end
