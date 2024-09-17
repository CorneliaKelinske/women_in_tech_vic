defmodule WomenInTechVicWeb.ContactLive do
  use WomenInTechVicWeb, :live_view
  alias WomenInTechVic.Accounts.User
  alias WomenInTechVic.Email.{Builder, Contact}
  alias WomenInTechVic.Mailer

  @form_params %{
    "from_email" => nil,
    "name" => nil,
    "subject" => nil,
    "message" => nil,
    "not_a_robot" => nil
  }

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

          <.input
            field={@form[:not_a_robot]}
            type="text"
            placeholder="Please enter the letters shown below"
            label="I am not a Robot!"
            required
          />

          <img
            src={"data:image/png;base64," <> @captcha_image}
            alt="CAPTCHA"
            class="mt-2 block w-full rounded-lg"
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
          Map.merge(@form_params, %{
            "from_email" => email,
            "name" => "#{first_name} #{last_name}"
          })

        _ ->
          @form_params
      end

    socket =
      socket
      |> assign(form: to_form(params))
      |> assign_captcha_image_and_form_id()

    {:ok, socket}
  end

  def handle_event("submit", %{"not_a_robot" => not_a_robot} = params, socket) do
    changeset = Contact.changeset(params)

    with {:ok, content} <- Ecto.Changeset.apply_action(changeset, :insert),
         :ok <- ExRoboCop.not_a_robot?({not_a_robot, socket.assigns.form_id}),
         %Swoosh.Email{} = message <- Builder.create_email(content),
         {:ok, _} <- Mailer.deliver(message) do
      info = "Your message has been sent successfully"

      {:noreply,
       socket
       |> put_flash(:info, info)
       |> redirect(to: ~p"/contact")}
    else
      {:error, :wrong_captcha} = error ->
        socket =
          socket
          |> put_flash(:error, build_error_message(error))
          |> assign_captcha_image_and_form_id()

        {:noreply, socket}

      error ->
        {:noreply, put_flash(socket, :error, build_error_message(error))}
    end
  end

  defp build_error_message({:error, :wrong_captcha}),
    do: "Your answer did not match the captcha. Please try again!"

  defp build_error_message({:error, %Ecto.Changeset{errors: [message: {message, _}]}}),
    do: message

  defp build_error_message(_), do: "Something went wrong"

  defp assign_captcha_image_and_form_id(socket) do
    {captcha_text, captcha_image} = ExRoboCop.create_captcha()
    form_id = ExRoboCop.create_form_id(captcha_text)
    assign(socket, captcha_image: captcha_image, form_id: form_id)
  end
end
