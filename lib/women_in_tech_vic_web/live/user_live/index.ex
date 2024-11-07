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
     |> assign_users()
     |> assign(show_modal: false)}
  end

  @impl true
  def handle_event("delete-user", %{"id" => user_id}, socket) do
    case Accounts.delete_user(String.to_integer(user_id)) do
      {:ok, %User{}} -> {:noreply, assign_users(socket)}
      _ -> {:noreply, put_flash(socket, :error, "Could not delete user")}
    end
  end

  # coveralls-ignore-start
  @impl true
  def handle_event("open-role-modal", %{"id" => user_id}, socket) do
    user = Accounts.get_user!(String.to_integer(user_id))

    {:noreply,
     socket
     |> assign(show_modal: true)
     |> assign(selected_user: user)}
  end

  @impl true
  def handle_event("close-modal", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  @impl true
  def handle_event("save-role", %{"role" => role, "user_id" => user_id}, socket) do
    case Accounts.update_user_role(String.to_integer(user_id), role) do
      {:ok, %User{}} ->
        {:noreply,
         socket
         |> assign(show_modal: false)
         |> assign_users()
         |> put_flash(:info, "User role updated successfully")}

      _ ->
        {:noreply,
         socket
         |> assign(show_modal: false)
         |> put_flash(:error, "Could not update user role")}
    end
  end

  # coveralls-ignore-stop

  defp assign_title(socket, title), do: assign(socket, title: title)

  defp assign_users(socket) do
    users = Accounts.all_users(%{})
    assign(socket, users: users)
  end
end
