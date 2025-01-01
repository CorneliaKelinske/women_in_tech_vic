defmodule WomenInTechVicWeb.MemberLive.Index do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]

  alias WomenInTechVic.Accounts

  @title "Our Members"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_title(@title)
     |> assign_users()}
  end

  defp assign_title(socket, title), do: assign(socket, title: title)

  defp assign_users(socket) do
    users = Accounts.all_users(%{order_by: :username, preload: :profile})
    assign(socket, users: users)
  end
end
