defmodule FaqcheckWeb.Upload.Components.Data do
  use FaqcheckWeb, :live_cmp

  def render(assigns) do
    ~L"""
    Uploaded files:
    <ul>
      <%= for f <- @uploaded_files do %>
      <li><%= f.filename %></li>
      <%  end %>
    </ul>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(uploaded_files: [])}
  end
end
