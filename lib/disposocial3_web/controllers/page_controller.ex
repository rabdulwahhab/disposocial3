defmodule Disposocial3Web.PageController do
  use Disposocial3Web, :controller

  def home(conn, _params) do
    conn
    |> assign(:page_title, "Home")
    |> render(:home)
  end
end
