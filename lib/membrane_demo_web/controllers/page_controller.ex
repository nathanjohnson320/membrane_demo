defmodule MembraneDemoWeb.PageController do
  use MembraneDemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
