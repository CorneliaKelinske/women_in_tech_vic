defmodule WomenInTechVicWeb.UserSettingsLive do
  use WomenInTechVicWeb, :live_view
  require Logger
  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.User
  @delete_account_form_params %{"password" => nil}
  @subscription_types Accounts.all_subscription_types()

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
      |> assign(:subscriptions_form, subscriptions_form_params())
      |> assign(:trigger_submit, false)
      |> assign(:subscription_types, @subscription_types)
      |> assign_user_subscriptions_and_types(user.id)

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

  def handle_event("update_subscriptions", params, socket) do
    user_subscriptions = MapSet.new(socket.assigns.user_subscription_types)

    submitted_subscriptions =
      params
      |> Stream.filter(fn {_, value} -> value === "true" end)
      |> Stream.map(fn {key, _} -> String.to_existing_atom(key) end)
      |> MapSet.new()

    to_add =
      submitted_subscriptions
      |> MapSet.difference(user_subscriptions)
      |> MapSet.to_list()

    to_remove =
      user_subscriptions
      |> MapSet.difference(submitted_subscriptions)
      |> then(
        &Enum.filter(socket.assigns.user_subscriptions, fn x -> x.subscription_type in &1 end)
      )

    with :ok <-
           Accounts.create_subscriptions_from_settings_form(
             socket.assigns.current_user.id,
             to_add
           ),
         :ok <- Accounts.delete_subscriptions_from_settings_form(to_remove) do
      {:noreply,
       socket
       |> assign_user_subscriptions_and_types(socket.assigns.current_user.id)
       |> assign(:subscriptions_form, subscriptions_form_params())
       |> put_flash(:info, "Subscriptions updated!")}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong! Please try again!")
         |> assign(:subscriptions_form, subscriptions_form_params())}
    end
  end

  defp assign_user_subscriptions_and_types(socket, user_id) do
    user_subscriptions = Accounts.all_subscriptions(%{user_id: user_id})
    user_subscription_types = Enum.map(user_subscriptions, & &1.subscription_type)

    assign(socket, %{
      user_subscriptions: user_subscriptions,
      user_subscription_types: user_subscription_types
    })
  end

  defp subscriptions_form_params do
    Enum.reduce(@subscription_types, %{}, &Map.put(&2, to_string(&1), false))
  end
end
