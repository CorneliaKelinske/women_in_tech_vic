defmodule WomenInTechVicWeb.HomeLive do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]

  @title "Welcome Home!"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, title: @title)}
  end
end
