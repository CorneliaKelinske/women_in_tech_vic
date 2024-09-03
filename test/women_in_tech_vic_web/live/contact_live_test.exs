defmodule WomenInTechVicWeb.ContactLiveTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]
  import Swoosh.TestAssertions, only: [assert_email_sent: 0]

  @valid_params %{
    from_email: "tester@test.com",
    name: "testy McTestface",
    subject: "Testing, testing",
    message: "Hello, this is a test"
  }

  setup [:user]

  describe "Contact form" do
    test "renders contact form", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/contact")

      assert html =~ "Contact the Admin"
      assert html =~ "Your email"
    end

    test "successfully sends contact form on submit", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/contact")

      render_submit(lv, :submit, @valid_params)
      assert_email_sent()
    end

    test "autofills email for logged in user", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/contact")

      assert html =~ user.email
    end
  end
end
