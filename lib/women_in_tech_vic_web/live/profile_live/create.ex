defmodule WomenInTechVicWeb.ProfileLive.Create do
  use WomenInTechVicWeb, :live_view

  on_mount {WomenInTechVicWeb.UserAuth, :redirect_if_profile_exists}

  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]
  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.Profile

  @title "Create Your User Profile"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_title(@title)
     |> assign_profile_form(Accounts.profile_changeset(%Profile{}))}
  end

  @impl true
  def handle_event("save-new-profile", %{"profile" => profile_params}, socket) do
    %{id: user_id} = socket.assigns.current_user
    profile_params = Map.put(profile_params, "user_id", to_string(user_id))

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
