defmodule WomenInTechVicWeb.UserSettingsLive do
  use WomenInTechVicWeb, :live_view
  require Logger
  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.User
  @delete_account_form_params %{"password" => nil}

  def render(assigns) do
    ~H"""
    <section class="relative text-gray-400 min-w-full">
      <div
        class="absolute inset-0 bg-cover bg-center"
        style="background-image: url('/images/code.jpg'); opacity: 0.3;"
      >
      </div>

      <div class="relative p-8 mx-auto max-w-3xl text-right md:text-center font-semibold font-sans text-2xl md:text-3xl md:tracking-widest z-10 text-gray-200">
        Account Settings
        <p class="mt-2 text-sm leading-6 font-normal md:tracking-normal">
          Manage your account email address and password settings
        </p>
      </div>
    </section>
    <.link
      navigate={~p"/home"}
      class="text-gray-200 mb-0 m-8 hover:text-gray-400 font-semibold uppercase flex items-center space-x-1"
    >
      <.icon name="hero-chevron-double-left" class="h-5 w-5" />
      <span>Home</span>
    </.link>

    <section class="w-full flex justify-center px-6 py-20 lg:px-8">
      <div class="w-full max-w-2xl space-y-12 divide-y 6 p-6 rounded-lg shadow-md mb-8 border border-gray-300 bg-gradient-to-r from-pink-200 via-gray-100 to-pink-300">
        <div>
          <.simple_form
            for={@email_form}
            id="email_form"
            phx-submit="update_email"
            phx-change="validate_email"
          >
            <.input field={@email_form[:email]} type="email" label="New Email" required />
            <.input
              field={@email_form[:current_password]}
              name="current_password"
              id="current_password_for_email"
              type="password"
              label="Current password"
              value={@email_form_current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Change Email</.button>
            </:actions>
          </.simple_form>
        </div>
        <div>
          <.simple_form
            for={@password_form}
            id="password_form"
            action={~p"/users/log_in?_action=password_updated"}
            method="post"
            phx-change="validate_password"
            phx-submit="update_password"
            phx-trigger-action={@trigger_submit}
          >
            <input
              name={@password_form[:email].name}
              type="hidden"
              id="hidden_user_email"
              value={@current_email}
            />
            <.input
              field={@password_form[:password]}
              type="password"
              label="New password"
              required
              phx-debounce
            />
            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label="Confirm new password"
              phx-debounce
            />
            <.input
              field={@password_form[:current_password]}
              name="current_password"
              type="password"
              label="Current password"
              id="current_password_for_password"
              value={@current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing...">Change Password</.button>
            </:actions>
          </.simple_form>
        </div>
        <div>
          <.simple_form
            for={@delete_account_form}
            id="delete_account_form"
            phx-submit="delete_account"
          >
            <.input field={@delete_account_form[:password]} type="password" label="Password" required />
            <:actions>
              <.button data-confirm="Are you sure?" phx-disable-with="Changing...">
                Delete Account
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </section>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:delete_account_form, to_form(@delete_account_form_params))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("delete_account", params, socket) do
    %{"password" => password} = params
    user = socket.assigns.current_user

    case Accounts.delete_account(user, password) do
      {:ok, %User{}} ->
        {:noreply,
         socket
         |> put_flash(:info, "So long and thanks for all the fish!")
         |> redirect(to: ~p"/")}

      {:error, %ErrorMessage{code: :unauthorized}} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid password! Please try again!")
         |> assign(:delete_account_form, to_form(@delete_account_form_params))}

      # coveralls-ignore-start
      error ->
        Logger.error("Error deleting user #{user.id}: #{inspect(error)}")

        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong! Please try again!") >
           assign(:delete_account_form, to_form(@delete_account_form_params))}

        # coveralls-ignore-stop
    end
  end
end
