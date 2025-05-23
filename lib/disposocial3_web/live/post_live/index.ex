defmodule Disposocial3Web.PostLive.Index do
  use Disposocial3Web, :live_view

  alias Disposocial3.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Posts
        <:actions>
          <.button variant="primary" navigate={~p"/posts/new"}>
            <.icon name="hero-plus" /> New Post
          </.button>
        </:actions>
      </.header>

      <.table
        id="posts"
        rows={@streams.posts}
        row_click={fn {_id, post} -> JS.navigate(~p"/posts/#{post}") end}
      >
        <:col :let={{_id, post}} label="Body">{post.body}</:col>
        <:action :let={{_id, post}}>
          <div class="sr-only">
            <.link navigate={~p"/posts/#{post}"}>Show</.link>
          </div>
          <.link navigate={~p"/posts/#{post}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, post}}>
          <.link
            phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Posts.subscribe_posts(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Posts")
     |> stream(:posts, Posts.list_posts(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Posts.get_post!(socket.assigns.current_scope, id)
    {:ok, _} = Posts.delete_post(socket.assigns.current_scope, post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_info({type, %Disposocial3.Posts.Post{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :posts, Posts.list_posts(socket.assigns.current_scope), reset: true)}
  end
end
