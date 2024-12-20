defmodule WomenInTechVicWeb.UserRegistrationLive do
  use WomenInTechVicWeb, :live_view

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center">
      <div class="bg-white bg-opacity-80 p-8 rounded-lg shadow-md w-full max-w-md mx-auto">
        <.header class="text-center text-zinc-900">
          Register for an account
          <:subtitle>
            Already registered?
            <.link navigate={~p"/users/log_in"} class="font-semibold text-purple-700 hover:underline">
              Log in
            </.link>
            to your account now.
          </:subtitle>
        </.header>

        <.simple_form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input field={@form[:email]} type="email" label="Email" required phx-debounce={500} />
          <.input
            field={@form[:password]}
            type="password"
            label="Password"
            required
            phx-debounce
            class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          />
          <.input
            field={@form[:first_name]}
            type="text"
            label="First name"
            required
            class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          />
          <.input
            field={@form[:last_name]}
            type="text"
            label="Last name"
            required
            class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          />
          <.input
            field={@form[:username]}
            type="text"
            label="Username"
            required
            class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
          />

          <:actions>
            <.button
              phx-disable-with="Creating account..."
              class="w-full bg-purple-700 text-white font-semibold py-3 rounded-lg hover:bg-purple-600"
            >
              Create an account
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        {:ok, _} = Accounts.deliver_admin_new_user_notification(user)

        socket =
          socket
          |> put_flash(
            :info,
            "Account created successfully. Please check your email for the confirmation link."
          )
          |> redirect(to: ~p"/")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
