defmodule Disposocial3Web.DispoLive.Index do
  use Disposocial3Web, :live_view

  alias Disposocial3.Dispos
  alias Disposocial3Web.Presence
  @default_radius 5  # Default Dispo discovery radius in miles

  defp dispo_topic(dispo_id) do
    "dispo:#{dispo_id}"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.container flash={@flash} current_scope={@current_scope}>
    <.header class="text-center">Dispos near you</.header>
    <div class="w-auto lg:w-3xl space-y-4 lg:mx-auto">
    <div class="flex flex-col items-center lg:flex-row gap-2 justify-between lg:justify-center">
      <div class="stats lg:grow">
        <div class="stat px-0">
          <div class="stat-title">Your location:</div>
          <div class="stat-value">
            <div phx-hook="GetLocation" id="location-hook" class="text-2xl">
              <%= if @location do %>
              <h6>{"#{elem(@location, 0)}, #{elem(@location, 1)}"}</h6>
              <% else %>
              <h6>---</h6>
              <% end %>
            </div>
          </div>
          <div class="stat-desc">
            <span :if={is_nil(@location)}>Finding your location...</span>
          </div>
        </div>
      </div>
      <.form for={@radius_form}>
        <.input label="Discover radius (miles)" type="select" phx-change="update_radius" name="discovery_radius" field={@radius_form[:discovery_radius]} options={[1, 5, 10, 25, "global"]}/>
      </.form>
      <.button patch={~p"/dispos/new"} class="btn-success btn-lg">
        Create a Dispo <.icon name="hero-plus" />
      </.button>
    </div>
    <section class="flex flex-col gap-4 sm:mt-2 lg:mt-6">
      <div :if={@location} id="dispos-empty" class="only:block hidden text-center">
        <p>No Dispos near you ☹️</p>
        <br>
        <.button patch={~p"/dispos/new"} class="btn-success">
          Create a Dispo <.icon name="hero-plus" />
        </.button>
      </div>
      <UI.dispo :for={{dispo_id, dispo} <- @streams.local_dispos} id={dispo_id} dispo={dispo} />
    </section>
    </div>
    </Layouts.container>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   Dispos.subscribe_dispos(socket.assigns.current_scope)
    # end

    {:ok,
      socket
      |> assign(:page_title, "Discover")
      |> assign_new(:location, fn -> nil end)
      |> assign_new(:radius_form, fn -> to_form(%{"discovery_radius" => @default_radius}) end)
      |> stream(:local_dispos, [])}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    dispo = Dispos.get_dispo!(socket.assigns.current_scope, id)
    {:ok, _} = Dispos.delete_dispo(socket.assigns.current_scope, dispo)

    {:noreply, stream_delete(socket, :dispos, dispo)}
  end

  @impl true
  def handle_info({type, %Disposocial3.Dispos.Dispo{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :dispos, Dispos.list_dispos(socket.assigns.current_scope), reset: true)}
  end


  @impl true
  def handle_info({Disposocial2Web.DispoLive.FormComponent, {:saved, dispo}}, socket) do
    {:noreply, stream_insert(socket, :local_dispos, dispo)}
  end

  @impl true
  def handle_event("update_radius", %{"discovery_radius" => new_radius}, socket) do
    if socket.assigns.location do
      {latitude, longitude} = socket.assigns.location
      local_dispos =
        if new_radius == "global" do
          Disposocial3.Repo.all(Disposocial3.Dispos.Dispo)
          |> Enum.map(fn dispo -> Map.put(dispo, :active_users, get_num_active_dispo_users(dispo.id)) end)
        else
          Dispos.get_all_near(latitude, longitude, new_radius)
          |> Enum.map(fn dispo -> Map.put(dispo, :active_users, get_num_active_dispo_users(dispo.id)) end)
        end
      # IO.inspect(local_dispos, label: "Local Dispos:")
      socket =
        socket
        |> assign(:discovery_radius, new_radius)
        |> stream(:local_dispos, local_dispos)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("location_updated", %{"lat" => latitude, "long" => longitude}, socket) do
    local_dispos =
      Dispos.get_all_near(latitude, longitude, socket.assigns.radius_form.params["discovery_radius"])
      |> Enum.map(fn dispo -> Map.put(dispo, :active_users, get_num_active_dispo_users(dispo.id)) end)
    # IO.inspect(local_dispos, label: "Local Dispos:")
    socket =
      socket
      |> assign(:location, {latitude, longitude})
      |> stream(:local_dispos, local_dispos)
    {:noreply, socket}
  end

  defp get_num_active_dispo_users(dispo_id) do
    map_size(Presence.list(dispo_topic(dispo_id)))
  end
end
