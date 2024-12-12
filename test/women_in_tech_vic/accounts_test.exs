defmodule WomenInTechVic.AccountsTest do
  use WomenInTechVic.DataCase

  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, user_2: 1, unconfirmed_user: 1]

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.{User, UserToken}
  alias WomenInTechVic.Support.AccountsFixtures

  @valid_password AccountsFixtures.valid_user_password()
  @unique_user_email AccountsFixtures.unique_user_email()

  setup [:user, :user_2, :unconfirmed_user]

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists", %{user: user} do
      id = user.id
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid", %{user: user} do
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid", %{user: user} do
      id = user.id

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, @valid_password)
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id", %{user: user} do
      id = user.id
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness", %{user: user} do
      email = user.email
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with a hashed password" do
      email = @unique_user_email

      user_params = AccountsFixtures.unconfirmed_user_attributes(%{email: email})

      {:ok, user} = Accounts.register_user(user_params)
      assert user.email === email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required === [:password, :email, :first_name, :last_name, :username]
    end

    test "allows fields to be set" do
      email = @unique_user_email
      password = @valid_password

      changeset =
        Accounts.change_user_registration(
          %User{},
          AccountsFixtures.valid_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) === email
      assert get_change(changeset, :password) === password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "find_user/1" do
    test "finds user by username", %{user: user} do
      username = user.username
      assert {:ok, %User{username: ^username}} = Accounts.find_user(%{username: username})
    end

    test "returns error if no user is found", %{user: user} do
      assert {:error, %ErrorMessage{code: :not_found, message: "no records found"}} =
               Accounts.find_user(%{id: user.id + 11})
    end
  end

  describe "all users/2" do
    test "returns a list of  all users" do
      assert [%User{}, %User{}, %User{}] = Accounts.all_users(%{})
    end

    test "returns empty list when no user found", %{user: user} do
      assert [] = Accounts.all_users(%{id: user.id + 10})
    end
  end

  describe "update_user/2" do
    test "updates a user when valid params are passed in", %{user: user} do
      assert %User{role: :admin} = user
      username = user.username
      id = user.id

      assert {:ok, %User{id: ^id, username: ^username, role: :member}} =
               Accounts.update_user(user, %{role: :member})
    end

    test "updates a user by ID when valid params are passed in", %{user: user} do
      assert %User{role: :admin} = user
      username = user.username
      id = user.id

      assert {:ok, %User{id: ^id, username: ^username, role: :member}} =
               Accounts.update_user(id, %{role: :member})
    end

    test "does not allow updating email address or password", %{user: user} do
      assert {:error,
              %ErrorMessage{
                code: :bad_request,
                message: "Cannot update email or password"
              }} = Accounts.update_user(user, %{password: "New Password"})
    end
  end

  describe "update_user_role/2" do
    test "updates a user role when valid params are passed in", %{user: user} do
      assert %User{role: :admin} = user
      username = user.username
      id = user.id

      assert {:ok, %User{id: ^id, username: ^username, role: :member}} =
               Accounts.update_user_role(id, :member)
    end

    test "returns error message tuple if invalid params are passed in", %{user: user} do
      assert {:error, %ErrorMessage{code: :not_found}} =
               Accounts.update_user_role(user.id + 12, :member)
    end
  end

  describe "delete user/1" do
    test "deletes a user", %{user: user} do
      assert {:ok, user} = Accounts.find_user(%{id: user.id})
      assert {:ok, %User{}} = Accounts.delete_user(user)

      assert {:error, %ErrorMessage{code: :not_found, message: "no records found"}} =
               Accounts.find_user(%{id: user.id})
    end

    test "deletes a user by user id", %{user: user} do
      assert {:ok, user} = Accounts.find_user(%{id: user.id})
      assert {:ok, %User{}} = Accounts.delete_user(user.id)

      assert {:error, %ErrorMessage{code: :not_found, message: "no records found"}} =
               Accounts.find_user(%{id: user.id})
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required === [:email, :first_name, :last_name, :username]
    end
  end

  describe "apply_user_email/3" do
    test "requires email to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, @valid_password, %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, @valid_password, %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_user_email(user, @valid_password, %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user, user_2: user_2} do
      email = user_2.email
      password = user.password

      {:error, changeset} = Accounts.apply_user_email(user, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, "invalid", %{email: @unique_user_email})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user} do
      email = @unique_user_email
      {:ok, user} = Accounts.apply_user_email(user, @valid_password, %{email: email})
      assert user.email === email
      assert Accounts.get_user!(user.id).email !== email
    end
  end

  describe "deliver_user_update_email_instructions/3" do
    test "sends token through notification", %{user: user} do
      token =
        AccountsFixtures.extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id === user.id
      assert user_token.sent_to === user.email
      assert user_token.context === "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup(%{user: user}) do
      email = @unique_user_email

      token =
        AccountsFixtures.extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert Accounts.update_user_email(user, token) === :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email !== user.email
      assert changed_user.email === email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at !== user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") === :error
      assert Repo.get!(User, user.id).email === user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) === :error
      assert Repo.get!(User, user.id).email === user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_user_email(user, token) === :error
      assert Repo.get!(User, user.id).email === user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required === [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) === "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, @valid_password, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, @valid_password, %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: @valid_password})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Accounts.update_user_password(user, @valid_password, %{
          password: "new valid password"
        })

      assert is_nil(user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, @valid_password, %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    test "generates a token", %{user: user, user_2: user_2} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context === "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_2.id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup(%{user: user}) do
      token = Accounts.generate_user_session_token(user)
      %{token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id === user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_user_session_token(token) === :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    test "sends token through notification", %{unconfirmed_user: unconfirmed_user} do
      token =
        AccountsFixtures.extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(unconfirmed_user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id === unconfirmed_user.id
      assert user_token.sent_to === unconfirmed_user.email
      assert user_token.context === "confirm"
    end
  end

  describe "confirm_user/1" do
    setup(%{unconfirmed_user: unconfirmed_user}) do
      token =
        AccountsFixtures.extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(unconfirmed_user, url)
        end)

      %{token: token}
    end

    test "confirms the email with a valid token", %{
      unconfirmed_user: unconfirmed_user,
      token: token
    } do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at !== unconfirmed_user.confirmed_at
      assert Repo.get!(User, unconfirmed_user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: unconfirmed_user.id)
    end

    test "does not confirm with invalid token", %{unconfirmed_user: unconfirmed_user} do
      assert Accounts.confirm_user("oops") === :error
      refute Repo.get!(User, unconfirmed_user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: unconfirmed_user.id)
    end

    test "does not confirm email if token expired", %{
      unconfirmed_user: unconfirmed_user,
      token: token
    } do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(token) === :error
      refute Repo.get!(User, unconfirmed_user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: unconfirmed_user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    test "sends token through notification", %{user: user} do
      token =
        AccountsFixtures.extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id === user.id
      assert user_token.sent_to === user.email
      assert user_token.context === "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup(%{user: user}) do
      token =
        AccountsFixtures.extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_user_password(user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user} = Accounts.reset_user_password(user, %{password: "new valid password"})
      assert is_nil(updated_user.password)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
