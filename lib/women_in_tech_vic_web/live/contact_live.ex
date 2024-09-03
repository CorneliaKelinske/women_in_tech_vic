defmodule WomenInTechVicWeb.ContactLive do
  use WomenInTechVicWeb, :live_view
  alias WomenInTechVic.Accounts.User
  alias WomenInTechVic.Email.{Builder, Contact}
  alias WomenInTechVic.Mailer

  @form_params %{"from_email" => nil, "name" => nil, "subject" => nil, "message" => nil}

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center">
      <div class="bg-white bg-opacity-80 p-8 rounded-lg shadow-md w-full max-w-md mx-auto">
        <.header class="text-center text-zinc-900">
          Contact the Admin
        </.header>

        <.simple_form for={@form} id="contact_form" phx-submit="submit">
          <.input field={@form[:name]} type="text" placeholder="Your name" label="Name" required />
          <.input
            field={@form[:from_email]}
            type="email"
            placeholder="Your email"
            label="Email"
            required
          />
          <.input
            field={@form[:subject]}
            type="text"
            placeholder="What is the subject of your message?"
            label="Subject"
            required
          />
          <.input
            field={@form[:message]}
            type="textarea"
            placeholder="Your message"
            label="Message"
            required
          />

          <.button
            phx-disable-with="Sending..."
            class="w-full bg-purple-700 text-white font-semibold py-3 rounded-lg hover:bg-purple-600"
          >
            Submit <span aria-hidden="true">→</span>
          </.button>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    params =
      case socket.assigns.current_user do
        %User{email: email, first_name: first_name, last_name: last_name} ->
          Map.merge(@form_params, %{"from_email" => email, "name" => "#{first_name} #{last_name}"})

        _ ->
          @form_params
      end

    {:ok, assign(socket, form: to_form(params, as: :email))}
  end

  def handle_event("submit", params, socket) do
    with %Ecto.Changeset{valid?: true, changes: changes} <- Contact.changeset(params),
         %Swoosh.Email{} = message <- Builder.create_email(changes),
         {:ok, _} <- Mailer.deliver(message) do
      info = "Your message has been sent successfully"

      {:noreply,
       socket
       |> put_flash(:info, info)
       |> redirect(to: ~p"/contact")}
    else
      _ ->
        error = "Something went wrong"
        {:noreply, put_flash(socket, :error, error)}
    end
  end
end
