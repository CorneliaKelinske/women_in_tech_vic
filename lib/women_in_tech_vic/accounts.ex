defmodule WomenInTechVic.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias EctoShorts.Actions
  alias WomenInTechVic.Repo
  alias WomenInTechVic.Accounts.{Profile, User, UserNotifier, UserToken}

  @type change_res(type) :: ErrorMessage.t_res(type) | {:error, Ecto.Changeset.t()}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  @spec get_user_by_email_and_password(String.t(), String.t()) :: User.t() | nil
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(pos_integer) :: User.t() | any()
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  @spec register_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_registration(User.t()) :: Ecto.Changeset.t()
  @spec change_user_registration(User.t(), map()) :: Ecto.Changeset.t()
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## User functions using Ecto.Shorts

  @doc false
  @spec find_user(map) :: ErrorMessage.t_res(User.t())
  def find_user(params) do
    Actions.find(User, params)
  end

  @doc false
  @spec all_users(map()) :: [User.t()]
  def all_users(params) do
    Actions.all(User, params)
  end

  @doc "especially useful for updating roles; can't be used for updating email and/or password"
  @spec update_user(pos_integer(), map()) :: change_res(User.t())
  @spec update_user(User.t(), map()) :: change_res(User.t())
  def update_user(_user_or_id, params)
      when is_map_key(params, :password) or is_map_key(params, :email) do
    {:error, ErrorMessage.bad_request("Cannot update email or password")}
  end

  @doc false
  @spec update_user(pos_integer(), map()) :: change_res(User.t())
  @spec update_user(User.t(), map()) :: change_res(User.t())
  def update_user(user_or_id, params) do
    Actions.update(User, user_or_id, params)
  end

  @doc false
  @spec update_user_role(pos_integer(), User.role()) :: change_res(User.t())
  def update_user_role(user_id, role) do
    Actions.update(User, user_id, %{role: role})
  end

  @doc "Used when user wants to delete their own account"
  @spec delete_account(User.t(), String.t()) :: change_res(User.t())
  def delete_account(user, password) do
    if User.valid_password?(user, password) do
      Actions.delete(user)
    else
      {:error, ErrorMessage.unauthorized("Incorrect password")}
    end
  end

  @doc false
  @spec delete_user(User.t() | pos_integer()) :: change_res(User.t())
  def delete_user(user_id) when is_integer(user_id) do
    Actions.delete(User, user_id)
  end

  def delete_user(user) do
    Actions.delete(user)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_email(User.t()) :: Ecto.Changeset.t()
  @spec change_user_email(User.t(), map()) :: Ecto.Changeset.t()
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec apply_user_email(User.t(), String.t(), map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  @spec update_user_email(User.t(), binary()) :: :ok | :error
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  @spec deliver_user_update_email_instructions(User.t(), String.t(), fun()) ::
          UserNotifier.swoosh_return()
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_password(User.t()) :: Ecto.Changeset.t()
  @spec change_user_password(User.t(), map()) :: Ecto.Changeset.t()
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user_password(User.t(), String.t(), map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  @spec generate_user_session_token(User.t()) :: binary()
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  @spec get_user_by_session_token(binary()) :: User.t() | nil
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  @spec delete_user_session_token(binary()) :: :ok
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  @spec deliver_user_confirmation_instructions(User.t(), fun()) ::
          UserNotifier.swoosh_return() | {:error, :already_returned}
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc "Notifies the admin when a new user signs up"
  @spec deliver_admin_new_user_notification(User.t()) :: UserNotifier.swoosh_return()
  def deliver_admin_new_user_notification(%User{} = user) do
    UserNotifier.deliver_admin_new_user_notification(user)
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  @spec confirm_user(binary()) :: {:ok, User.t()} | :error
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  @spec deliver_user_reset_password_instructions(User.t(), fun()) :: UserNotifier.swoosh_return()
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  @spec get_user_by_reset_password_token(binary()) :: User.t() | nil
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  @spec reset_user_password(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  # PROFILES

  @doc false
  @spec create_profile(map) :: change_res(Profile.t())
  def create_profile(params) do
    Actions.create(Profile, params)
  end

  @doc false
  @spec find_profile(map) :: ErrorMessage.t_res(Profile.t())
  def find_profile(params) do
    Actions.find(Profile, params)
  end

  @doc false
  @spec all_profiles(map()) :: [Profile.t()]
  def all_profiles(params) do
    Actions.all(Profile, params)
  end

  @doc false
  @spec update_profile(pos_integer(), map()) :: change_res(Profile.t())
  @spec update_profile(Profile.t(), map()) :: change_res(Profile.t())
  def update_profile(id_or_schema, params) do
    Actions.update(Profile, id_or_schema, params)
  end

  @doc "called in event handlers; checking that only owner can update their profile"
  @spec update_profile_by_owner(Profile.t(), map(), User.t()) :: change_res(Profile.t())
  def update_profile_by_owner(%Profile{user_id: profile_user_id} = profile, params, %User{
        id: profile_user_id
      }) do
    Actions.update(Profile, profile, params)
  end

  def update_profile_by_owner(_profile, _param, _user) do
    {:error, ErrorMessage.unauthorized("Not authorized to update this profile")}
  end

  @doc false
  @spec delete_profile(Profile.t()) :: change_res(Profile.t())
  def delete_profile(profile) do
    Actions.delete(profile)
  end

  @doc "called in event handlers; checking that only owner can delete their profile"
  @spec delete_profile_by_owner(pos_integer(), pos_integer(), User.t()) :: change_res(Profile.t())
  def delete_profile_by_owner(profile_id, profile_user_id, %{id: profile_user_id}) do
    Actions.delete(Profile, profile_id)
  end

  def delete_profile_by_owner(_profile_id, _profile_user_id, _user) do
    {:error, ErrorMessage.unauthorized("Not authorized to delete this profile")}
  end

  @doc "creates an Profile changeset with nil values"
  @spec profile_changeset(Profile.t(), map()) :: Ecto.Changeset.t()
  @spec profile_changeset(Profile.t()) :: Ecto.Changeset.t()
  def profile_changeset(profile, params \\ %{}) do
    Profile.changeset(profile, params)
  end
end
