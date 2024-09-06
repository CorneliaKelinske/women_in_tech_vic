defmodule WomenInTechVicWeb.ContactLiveTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]
  import Swoosh.TestAssertions, only: [assert_no_email_sent: 0, assert_email_sent: 0]

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

    test "does not send contact form on submit when incorrect captcha is provided", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/contact")

      params = Map.merge(@valid_params, %{not_a_robot: "wrong answer"})
      html = render_submit(lv, :submit, params)
      assert html =~ "Your answer did not match the captcha. Please try again"

      assert_no_email_sent()
    end

    test "sends contact form on submit when correct captcha is provided", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/contact")
      socket_state = :sys.get_state(lv.pid)
      form_id = socket_state.socket.assigns.form_id

      {:ok, captcha_answer} = ExRoboCop.get_answer_for_form_id(form_id)

      params = Map.merge(@valid_params, %{not_a_robot: captcha_answer})
      render_submit(lv, :submit, params)

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
