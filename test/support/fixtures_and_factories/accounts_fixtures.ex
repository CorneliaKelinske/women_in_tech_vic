defmodule WomenInTechVic.Support.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WomenInTechVic.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      first_name: Faker.Person.first_name() <> "#{System.unique_integer()}",
      last_name: Faker.Person.last_name() <> "#{System.unique_integer()}",
      username: Faker.Pokemon.name() <> "#{System.unique_integer()}",
      confirmed_at: DateTime.utc_now()
    })
  end

  def unconfirmed_user_attributes(attrs \\ %{}) do
    attrs
    |> Enum.into(valid_user_attributes())
    |> Map.delete(:confirmed_at)
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> WomenInTechVic.Accounts.register_user()

    user
  end

  def admin_user_fixture(attrs \\ %{}) do
    {:ok, admin_user} =
      attrs
      |> valid_user_attributes()
      |> Map.put(:role, :admin)
      |> WomenInTechVic.Accounts.register_user()

    admin_user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
