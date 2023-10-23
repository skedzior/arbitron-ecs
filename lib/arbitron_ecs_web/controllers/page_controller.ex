defmodule ArbitronWeb.PageController do
  use ArbitronWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
