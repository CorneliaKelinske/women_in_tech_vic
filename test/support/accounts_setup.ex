defmodule WomenInTechVic.Support.AccountsTestSetup do
  @moduledoc """
  Used for importing pre-created accounts resources in accounts tests:

  ```
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]
  ```

  """

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
end
