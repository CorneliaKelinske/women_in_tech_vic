defmodule WomenInTechVic.Accounts.UserNotifier do
  @moduledoc false
  import Swoosh.Email, only: [new: 0, from: 2, to: 2, subject: 2, text_body: 2]

  alias WomenInTechVic.Accounts.User
  alias WomenInTechVic.Content.Event
  alias WomenInTechVic.Mailer

  @type swoosh_return :: {:ok, Swoosh.Email.t()} | {:error, any()}
  @type event_action :: :create | :update | :delete

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"WomenInTechVic", "donotreply@witv.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  @spec deliver_confirmation_instructions(User.t(), String.t()) :: swoosh_return()
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver a notification that a new user has signed up to the page Admin.
  """
  @spec deliver_admin_new_user_notification(User.t()) :: swoosh_return()
  def deliver_admin_new_user_notification(%User{} = user) do
    deliver("corneliakelinske@gmail.com", "New user registered", """

    ==============================

    Hi Cornelia,

    A new user has registered for the Women in Tech Vic website.
    Here is their info:

    Email: #{user.email}
    First name: #{user.first_name}
    Last name: #{user.last_name}
    Username: #{user.username}

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  @spec deliver_reset_password_instructions(User.t(), String.t()) :: swoosh_return()
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  @spec deliver_update_email_instructions(User.t(), String.t()) :: swoosh_return()
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @spec deliver_new_event_created_notification(Event.t(), User.t()) :: swoosh_return()
  def deliver_new_event_created_notification(event, user) do
    deliver(user.email, "New event created", """
    ==============================

    Hi #{user.first_name},

    A new Women in Tech Victorian event has been posted.
    Here is the event info:

    #{event.title} on #{event.scheduled_at} at #{event.address}.

    Visit the website for more details and to RSVP.

    We hope to see you there!

    ==============================
    """)
  end

  @spec deliver_event_update_notification(Event.t(), User.t(), event_action()) :: swoosh_return()
  def deliver_event_update_notification(event, user, action) when action in [:create, :update] do
    deliver(user.email, "Event #{to_string(action)}d", """
    ==============================

    Hi #{user.first_name},

    A Women in Tech Victorian event has been #{to_string(action)}d.
    Here is the event info:

    #{event.title} on #{event.scheduled_at} at #{event.address}.

    Visit the website for more details and to RSVP.

    We hope to see you there!

    ==============================
    """)
  end

  def deliver_event_update_notification(event, user, :delete) do
    deliver(user.email, "Event deleted", """
    ==============================

    Hi #{user.first_name},

    Unfortunately the following Women in Tech Victoria event has been cancelled:

    #{event.title} on #{event.scheduled_at} at #{event.address}.

    Visit the website to find other events.

    We hope to see you soon!

    ==============================
    """)
  end
end
