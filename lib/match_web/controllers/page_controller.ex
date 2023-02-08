defmodule MatchWeb.PageController do
  use MatchWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
