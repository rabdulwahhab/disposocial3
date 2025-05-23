defmodule Disposocial3Web.DispoLive.Show do
  use Disposocial3Web, :live_view
  require Logger

  alias Disposocial3.{Dispos, DispoRegistry, DispoServer, Posts, Accounts.Scope}
  alias Disposocial3Web.{Presence, Endpoint}

  defp dispo_topic(dispo_id) do
    "dispo:#{dispo_id}"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <UI.drawer>
        <!-- Page content here -->
        <.header class="sticky top-0 z-10 bg-base-100 py-2">
          <div class="flex flex-row justify-between">
            <div>{@dispo.name}</div>
            <label for="my-drawer" class="btn btn-ghost drawer-button lg:hidden">
              <.icon name="hero-bars-3" class="size-5" />
            </label>
          </div>
          <:subtitle><span class="wrap-anywhere">{@dispo.description}</span></:subtitle>
        </.header>
        <!-- Posts container -->
        <UI.posts_container id="posts-container" posts={@streams.posts} current_scope={@current_scope} />
        <.live_component module={Disposocial3Web.PostLive.Form} id="new-post-live-comp" current_scope={@current_scope} />
        <!-- End page content -->
        <:sidebar_content>
          <!-- Sidebar content here -->
          <li class="list-row">
            <.button navigate={~p"/discover"} variant="error" class="btn-error">
              <.icon name="hero-arrow-left" />Leave
            </.button>
            <.button :if={@current_scope.user.id == @dispo.user_id} variant="primary" navigate={~p"/dispos/#{@dispo}/edit?return_to=show"}>
              <.icon name="hero-pencil-square" /> Edit dispo
            </.button>
          </li>
          <li class="list-row">
            <.icon name="hero-map-pin" />
            <p>{@dispo.location}</p>
            <p class="italic list-col-wrap">{"#{@dispo.latitude}, #{@dispo.longitude}"}</p>
          </li>
          <li class="list-row">
            <.icon class="size-4 text-error" name="hero-exclamation-circle" />
            <p class="text-error">Expiring:</p>
            <p class="text-error">{Util.display_death_datetime(@dispo.death)}</p>
          </li>
          <li>
            <div class="collapse collapse-arrow collapse-open">
              <input type="checkbox" />
              <div class="collapse-title font-semibold content-center">
                <.icon name="hero-users" />
                <span class="px-3">Online</span>
              </div>
              <div id="connected-users" phx-update="stream" class="collapse-content text-sm">
                <%= for {connected_user_dom_id, user} <- @streams.connected_users do %>
                <div id={connected_user_dom_id}>
                  <span>
                    <div aria-label="success" class="status status-success mx-3"></div>
                    {user.username}
                    <span :if={user.id == @current_scope.user.id}>(Me)</span>
                  </span>
                </div>
                <% end %>
              </div>
            </div>
          </li>
        </:sidebar_content>
      </UI.drawer>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    dispo_id = String.to_integer(id)
    dispo = DispoServer.get_dispo(dispo_id)
    if connected?(socket) do
      Dispos.subscribe_dispos(socket.assigns.current_scope)
      Presence.track(
        self(),
        dispo_topic(dispo_id),
        socket.assigns.current_scope.user.id,
        %{
          id: socket.assigns.current_scope.user.id,
          username: socket.assigns.current_scope.user.username,
          online_at: inspect(System.system_time(:second))
        }
      )
      Endpoint.subscribe(dispo_topic(dispo_id))
      recent_posts = DispoServer.get_recent_posts(dispo_id)
      connected_users = get_connected_dispo_users(dispo_id)
      socket =
        socket
        |> stream(:posts, recent_posts)
        |> stream(:connected_users, connected_users)
        |> assign(:current_scope, Scope.for_dispo(socket.assigns.current_scope, dispo))
        |> assign(:dispo, dispo)
        |> assign(:page_title, dispo.name)
        |> assign(:announcements, [])
      {:ok, socket}
    else
      socket =
        socket
        |> stream(:posts, [])
        |> stream(:connected_users, [])
        |> assign(:current_scope, Scope.for_dispo(socket.assigns.current_scope, %Dispos.Dispo{}))
        |> assign(:dispo, dispo)
        |> assign(:page_title, "Joining Dispo")
        |> assign(:announcements, [])
      {:ok, socket}
    end
  end

  @impl true
  def handle_info({Disposocial3Web.PostLive.Form, {:new_post, post}}, socket) do
    Endpoint.broadcast_from(self(), dispo_topic(socket.assigns.current_scope.dispo.id), "new_post", %{post: post})
    {:noreply,
      socket
      |> stream_insert(:posts, post, at: 0)
      |> put_flash(:info, "Posted!")}
  end

  @impl true
  def handle_info(
        {:updated, %Disposocial3.Dispos.Dispo{id: id} = dispo},
        %{assigns: %{dispo: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :dispo, dispo)}
  end

  def handle_info(
        {:deleted, %Disposocial3.Dispos.Dispo{id: id}},
        %{assigns: %{dispo: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The Dispo expired")
     |> push_navigate(to: ~p"/discover")}
  end

  def handle_info({type, %Disposocial3.Dispos.Dispo{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "new_post", payload: %{post: post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  @impl true
  def handle_info(%{event: "user_joined", payload: %{user: username}}, socket) do
    # TODO put flash
    {:noreply, assign(socket, :announcements, ["#{username} joined." | socket.assigns.announcements])}
  end

  @impl true
  def handle_info(%{event: "death_reminder", payload: %{seconds_left: seconds_left}}, socket) do
    # IO.inspect(seconds_left, label: "handle info:death_reminder")
    death_dt = DateTime.utc_now() |> DateTime.add(seconds_left, :second)
    {:noreply, put_flash(socket, :info, Util.display_relative_time_future(death_dt))}
  end

  @impl true
  def handle_info(%{event: "angel_of_death", payload: _payload}, socket) do
    {:noreply,
      socket
      |> put_flash(:error, "Dispo gone")
      |> redirect(to: ~p"/discover")}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    # IO.puts "LiveView presence diff for #{socket.assigns.current_user.name}"
    # IO.inspect(joins, label: "JOINS")
    # IO.inspect(leaves, label: "LEAVES")
    {:noreply,
      socket
      |> process_joins(joins)
      |> process_leaves(leaves)}
  end

  defp get_connected_dispo_users(dispo_id) do
    Presence.list(dispo_topic(dispo_id))
    # |> IO.inspect(label: "get connected users list")
    |> Enum.map(fn {_user_id, data} -> data[:metas] |> List.first() end)
  end

  defp process_joins(socket, joins) when map_size(joins) == 0, do: socket
  defp process_joins(socket, joins) do
    joins
    |> Enum.map(fn {_user_id, data} -> data[:metas] |> List.first() end)
    # |> IO.inspect(label: "joined users")
    |> Enum.reduce(socket, fn joined_user, socket_acc -> stream_insert(socket_acc, :connected_users, joined_user) end)
  end

  defp process_leaves(socket, leaves) when map_size(leaves) == 0, do: socket
  defp process_leaves(socket, leaves) do
    leaves
    |> Enum.map(fn {_user_id, data} -> data[:metas] |> List.first() end)
    # |> IO.inspect(label: "left users")
    |> Enum.reduce(socket, fn left_user, socket_acc -> stream_delete(socket_acc, :connected_users, left_user) end)
  end
end
