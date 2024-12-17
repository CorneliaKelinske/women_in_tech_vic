defmodule WomenInTechVic.Support.AccountsTestSetup do
  @moduledoc """
  Used for importing pre-created accounts resources in accounts tests:

  ```
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]
  ```

  """

  import WomenInTechVic.Support.Factory, only: [insert: 1, build: 1]
  alias WomenInTechVic.Accounts.Profile
  alias WomenInTechVic.Support.AccountsFixtures

  # This is an admin user
  def user(_) do
    user = AccountsFixtures.admin_user_fixture()

    %{user: user}
  end

  def user_2(_) do
    user_2 = AccountsFixtures.user_fixture()

    %{user_2: user_2}
  end

  def unconfirmed_user(_) do
    unconfirmed_user = AccountsFixtures.user_fixture(confirmed_at: nil)

    %{unconfirmed_user: unconfirmed_user}
  end

  def profile(%{user: user}) do
    profile =
      :profile
      |> build()
      |> Map.merge(%{user_id: user.id})
      |> then(&struct!(Profile, &1))
      |> insert()

    %{profile: profile}
  end
end
