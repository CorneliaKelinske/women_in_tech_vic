defmodule WomenInTechVicWeb.PageControllerTest do
  use WomenInTechVicWeb.ConnCase

  import WomenInTechVic.Support.Factory, only: [insert: 1, build: 2]
  alias WomenInTechVic.Content.Event

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ ">Welcome to Women in Tech Victoria</h1>\n"
  end

  test "shows message when no meeting has been scheduled", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "No event scheduled"
  end

  test "shows event title when meeting has been scheduled", %{conn: conn} do
    :online_event
    |> build(title: "Bi-weekly online meeting")
    |> then(&struct!(Event, &1))
    |> insert()

    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Bi-weekly online meeting"
  end
end
