defmodule Disposocial3Web.UI do
  @moduledoc """
  This module holds my various, custom UI used throughout the application.

  See the `ui` directory for all components available.
  """
  use Disposocial3Web, :html
  alias Disposocial3.Posts.Post
  alias Disposocial3.Accounts.Scope

  embed_templates "ui/*"

  def hero(assigns) do
    ~H"""
    <div class="hero min-h-screen">
      <div class="flex flex-col items-center text-center">
        <img src={~p"/images/logo.png"} class="w-50 rounded-full" />
        <div>
          <h1 class="text-5xl font-bold">{@title}</h1>
          <p class="py-6">
            {@subtitle}
          </p>
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  def dispo(assigns) do
    ~H"""
    <div id={@id} class="card w-full bg-base-200">
      <div class="card-body">
        <div class="flex flex-wrap gap-2">
          <%= if @dispo.is_public do %>
            <span class="badge badge-xs badge-info">Public</span>
          <% else %>
            <span class="badge badge-xs badge-info">Private</span>
          <% end %>
          <span class="badge badge-xs badge-success">Online: {@dispo.active_users}</span>
        </div>
        <div class="flex justify-between">
          <h2 class="text-3xl font-bold">{@dispo.name}</h2>
          <span class="text-xl">{"#{@dispo.latitude}, #{@dispo.longitude}"}</span>
        </div>
        <div class="flex flex-wrap gap-2 font-light">
          <span>{"Created: #{Util.display_relative_time_past(@dispo.inserted_at)}"}</span>
          <span class="text-error">
            {"Expiration: #{Util.display_relative_time_future(@dispo.death)}"}
          </span>
        </div>
        <div class="flex flex-wrap justify-between items-end">
          <div class="flex-2/3 font-semibold">
            {@dispo.description}
          </div>
          <div>
            <.button
              :if={@dispo.is_public}
              navigate={~p"/dispos/#{@dispo.id}"}
              class="btn-primary btn-lg"
            >
              Join<span aria-hidden="true">&rarr;</span>
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :posts, :list, required: true
  attr :current_scope, Scope, required: true
  attr :rest, :global

  def posts_container(assigns) do
    ~H"""
    <%!-- <div class="py-6 w-full h-full border border-success" {@rest}> --%>
    <div
      id={@id}
      phx-update="stream"
      phx-hook="AutoScrollToBottom"
      class="flex flex-col-reverse py-6 overflow-y-auto w-full h-3/4"
      {@rest}
    >
      <.post
        :for={{post_dom_id, post} <- @posts}
        id={post_dom_id}
        post={post}
        current_scope={@current_scope}
      />
    </div>
    """
  end

  attr :id, :string, required: true
  attr :post, Post, required: true
  attr :current_scope, Scope, required: true

  def post(assigns) do
    ~H"""
    <div
      id={@id}
      class={"chat wrap-anywhere #{if @post.user_id == @current_scope.user.id, do: "chat-end", else: "chat-start"}"}
    >
      <div class="chat-header">
        {@post.user.username}
        <time class="text-xs opacity-50">
          {Util.display_post_time(@post.inserted_at, @current_scope.user.timezone)}
        </time>
      </div>
      <div class="chat-bubble">{@post.body}</div>
      <%!-- <div class="chat-footer opacity-50">Seen</div> --%>
    </div>
    """
  end

  slot :sidebar_content, required: true
  slot :inner_block, required: true

  def drawer(assigns) do
    ~H"""
    <div class="drawer lg:drawer-open h-full">
      <input id="my-drawer" type="checkbox" class="drawer-toggle" />
      <div class="drawer-content min-h-0 h-full px-1 lg:px-4">
        <!-- Page content here -->
        {render_slot(@inner_block)}
      </div>
      <div class="drawer-side z-20">
        <label for="my-drawer" aria-label="close sidebar" class="drawer-overlay"></label>
        <ul class="list bg-base-200 text-base-content w-80 p-4 gap-2 h-full">
          <!-- Sidebar content here -->
          {render_slot(@sidebar_content)}
        </ul>
      </div>
    </div>
    """
  end
end
