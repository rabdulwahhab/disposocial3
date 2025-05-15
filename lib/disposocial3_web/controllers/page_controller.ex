defmodule Disposocial3Web.PageController do
  use Disposocial3Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
