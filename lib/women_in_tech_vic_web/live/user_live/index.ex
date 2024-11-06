defmodule WomenInTechVicWeb.UserLive.Index do
  use WomenInTechVicWeb, :live_view

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.User

  @title "All Users"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_title(@title)
     |> assign_users()}
  end

  @impl true
  def handle_event("delete-user", %{"id" => user_id}, socket) do
    case Accounts.delete_user(String.to_integer(user_id)) do
      {:ok, %User{}} -> {:noreply, assign_users(socket)}
      _ -> {:noreply, put_flash(socket, :error, "Could not delete user")}
    end
  end

  defp assign_title(socket, title), do: assign(socket, title: title)

  defp assign_users(socket) do
    users = Accounts.all_users(%{})
    assign(socket, users: users)
  end
end
