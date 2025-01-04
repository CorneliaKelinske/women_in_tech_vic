defmodule WomenInTechVicWeb.ProfileLive.Create do
  use WomenInTechVicWeb, :live_view

  # on_mount {WomenInTechVicWeb.UserAuth, :redirect_if_profile_exists}

  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]
  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.Profile

  @title "Create Your User Profile"

  @impl true
  def mount(_params, _session, socket) do
    %{id: user_id} = socket.assigns.current_user

    case Accounts.find_profile(%{user_id: user_id}) do
      {:ok, %Profile{}} ->
        {:ok,
         socket
         |> push_navigate(to: ~p"/profiles/#{user_id}")}

      _ ->
        {:ok,
         socket
         |> assign_title(@title)
         |> assign_profile_form(Accounts.profile_changeset(%Profile{}))
         |> assign(:uploaded_files, [])
         |> allow_upload(:image,
           accept: ~w(.jpg .jpeg .png),
           max_entries: 1,
           max_file_size: 2_000_000
         )}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save-new-profile", %{"profile" => profile_params}, socket) do
    %{id: user_id} = socket.assigns.current_user

    file_path =
      socket
      |> consume_uploaded_entries(:image, fn %{path: path}, _entry ->
        dest =
          Path.join(
             "priv/static/uploads",
            Path.basename(path)
          )

        # You will need to create priv/static/uploads for File.cp!/2 to work.
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)
      |> List.first()

    profile_params =
      Map.merge(profile_params, %{"user_id" => to_string(user_id), "picture_path" => file_path})

    case Accounts.create_profile(profile_params) do
      {:ok, %Profile{}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Created profile")
         |> push_navigate(to: ~p"/profiles/#{user_id}")}

      # This is a highly unlikely error, since none of the user provided fields are unique or required
      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong, please try again")
         |> push_navigate(to: ~p"/")}
    end
  end

  defp assign_title(socket, title), do: assign(socket, title: title)

  defp assign_profile_form(socket, changeset) do
    assign(socket, :new_profile_form, to_form(changeset))
  end
end
