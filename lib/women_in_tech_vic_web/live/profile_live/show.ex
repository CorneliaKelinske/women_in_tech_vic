defmodule WomenInTechVicWeb.ProfileLive.Show do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.{Profile, User}
  alias WomenInTechVicWeb.ProfileLive.UploadUtils

  @title "Profile"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Accounts.find_user(%{id: id, preload: :profile}) do
      {:ok, %User{username: username} = user} ->
        edit_profile_changeset = Accounts.profile_changeset(user.profile || %Profile{})

        {:ok,
         socket
         |> assign_title("#{username}'s #{@title}")
         |> assign_profile_owner(user)
         |> assign_uploaded_files()
         |> allow_upload(:image,
           accept: ~w(.jpg .jpeg .png),
           max_entries: 1,
           max_file_size: 4_000_000
         )
         |> assign_edit_profile_form(edit_profile_changeset)}

      _ ->
        {:ok,
         socket
         |> put_flash(:error, "Something went wrong. Please try again")
         |> push_navigate(to: ~p"/")}
    end
  end

  # coveralls-ignore-start
  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  # coveralls-ignore-stop

  @impl true
  def handle_event("save-profile", %{"profile" => profile_params}, socket) do
    user = socket.assigns.profile_owner

    # coveralls-ignore-start
    file_path = UploadUtils.create_image_upload_with_path(socket)

    profile_params =
      case file_path do
        nil -> profile_params
        _ -> Map.put(profile_params, "picture_path", file_path)
      end

    # coveralls-ignore-stop

    case Accounts.update_profile_by_owner(
           user.profile,
           profile_params,
           socket.assigns.current_user
         ) do
      {:ok, updated_profile} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile updated successfully.")
         |> push_navigate(to: ~p"/profiles/#{user.id}")
         |> assign(:profile_owner, %{user | profile: updated_profile})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :edit_profile_form, to_form(changeset))}
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
        {:noreply, push_navigate(socket, to: ~p"/profiles/#{user_id}/create")}

      _ ->
        {:noreply, put_flash(socket, :error, "Could not delete profile")}
    end
  end

  defp assign_title(socket, title), do: assign(socket, title: title)

  defp assign_uploaded_files(socket), do: assign(socket, uploaded_files: [])

  defp assign_profile_owner(socket, user), do: assign(socket, profile_owner: user)

  defp assign_edit_profile_form(socket, changeset) do
    assign(socket, :edit_profile_form, to_form(changeset))
  end

  # coveralls-ignore-start
  defp upload_error_to_string(:too_large), do: "The file is too large"
  defp upload_error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp upload_error_to_string(_), do: "Hm, something went wrong. Please try again"
  # coveralls-ignore-stop
end
