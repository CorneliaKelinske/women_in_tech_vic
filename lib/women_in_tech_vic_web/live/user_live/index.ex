defmodule WomenInTechVicWeb.UserLive.Index do
  use WomenInTechVicWeb, :live_view

  alias WomenInTechVic.Accounts

  @title "All Users"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_title(@title)
     |> assign_users()}
  end

  defp assign_title(socket, title), do: assign(socket, title: title)

  defp assign_users(socket) do
    users = Accounts.all_users(%{})
    assign(socket, users: users)
  end
end
