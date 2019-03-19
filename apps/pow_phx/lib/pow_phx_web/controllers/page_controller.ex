defmodule PowPhxWeb.PageController do
  use PowPhxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
