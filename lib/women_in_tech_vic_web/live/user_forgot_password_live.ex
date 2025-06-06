defmodule WomenInTechVicWeb.UserForgotPasswordLive do
  use WomenInTechVicWeb, :live_view

  alias WomenInTechVic.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center">
      <div class="bg-white bg-opacity-80 p-8 rounded-lg shadow-md w-full max-w-md mx-auto">
        <.header class="text-center">
          Forgot your password?
          <:subtitle>We'll send a password reset link to your inbox</:subtitle>
        </.header>

        <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
          <.input field={@form[:email]} type="email" placeholder="Email" required />
          <:actions>
            <.button
              phx-disable-with="Sending..."
              class="w-full bg-purple-700 text-white font-semibold py-3 rounded-lg hover:bg-purple-600"
            >
              Send password reset instructions
            </.button>
          </:actions>
        </.simple_form>
        <p class="text-center mt-4">
          <.link href={~p"/users/register"}>Register</.link>
          | <.link href={~p"/users/log_in"}>Log in</.link>
        </p>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
