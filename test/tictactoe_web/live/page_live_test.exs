defmodule TictactoeWeb.PageLiveTest do
  use TictactoeWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Play with bot"
    assert render(page_live) =~ "Play with bot"
  end
end
