defmodule WomenInTechVicWeb.PageControllerTest do
  use WomenInTechVicWeb.ConnCase

  import WomenInTechVic.Support.Factory, only: [insert: 1, build: 2]
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]
  alias WomenInTechVic.Content.Event
  alias WomenInTechVic.Support.AccountsFixtures

  @valid_password AccountsFixtures.valid_user_password()
  setup [:user]

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ ">Welcome to Women in Tech Victoria</h1>\n"
  end

  test "redirects logged in users", %{conn: conn, user: user} do
    conn =
      post(conn, ~p"/users/log_in", %{
        "user" => %{"email" => user.email, "password" => @valid_password}
      })

    assert redirected_to(conn) === ~p"/events"
  end

  test "shows message when no meeting has been scheduled", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "No event scheduled"
  end

  test "shows event title when meeting has been scheduled, but not the address", %{
    conn: conn,
    user: user
  } do
    :online_event
    |> build(title: "Bi-weekly online meeting")
    |> Map.put(:user_id, user.id)
    |> then(&struct!(Event, &1))
    |> insert()

    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Bi-weekly online meeting"
    refute html_response(conn, 200) =~ "meet.google.com"
    assert html_response(conn, 200) =~ "See details"
  end
end
