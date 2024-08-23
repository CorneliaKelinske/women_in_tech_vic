defmodule WomenInTechVicWeb.UserLoginLive do
  use WomenInTechVicWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center">
      <div class="bg-white bg-opacity-80 p-8 rounded-lg shadow-md w-full max-w-md mx-auto">
        <.header class="text-center text-zinc-900">
          Log in to account
          <:subtitle>
            Don't have an account?
            <.link
              navigate={~p"/users/register"}
              class="font-semibold text-purple-700 hover:underline"
            >
              Sign up
            </.link>
            for an account now.
          </:subtitle>
        </.header>

        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Password" required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
            <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
              Forgot your password?
            </.link>
          </:actions>
          <:actions>
            <.button
              phx-disable-with="Logging in..."
              class="w-full bg-purple-700 text-white font-semibold py-3 rounded-lg hover:bg-purple-600"
            >
              Log in <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
