defmodule WomenInTechVicWeb.ProfileLive.Show do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.{Profile, User}

  @title "Profile"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Accounts.find_user(%{id: id, preload: :profile}) do
      {:ok, %User{username: username} = user} ->
        {:ok,
         socket
         |> assign_title("#{username}'s #{@title}")
         |> assign_profile_owner(user)}

      _ ->
        {:ok,
         socket
         |> put_flash(:error, "Something went wrong. Please try again")
         |> push_navigate(to: ~p"/")}
    end
  end

  @impl true
  def handle_event("delete_profile", %{"id" => profile_id, "profile-user-id" => user_id}, socket) do
    case Accounts.delete_profile_by_owner(
           String.to_integer(profile_id),
           String.to_integer(user_id),
           socket.assigns.current_user
         ) do
      {:ok, %Profile{}} ->
        {:noreply, push_navigate(socket, to: ~p"/profiles/create/#{user_id}")}

      _ ->
        {:noreply, put_flash(socket, :error, "Could not delete profile")}
    end
  end

  defp assign_title(socket, title), do: assign(socket, title: title)

  defp assign_profile_owner(socket, user), do: assign(socket, profile_owner: user)
end
