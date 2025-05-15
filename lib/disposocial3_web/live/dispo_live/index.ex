defmodule Disposocial3Web.DispoLive.Index do
  use Disposocial3Web, :live_view

  alias Disposocial3.Dispos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Dispos
        <:actions>
          <.button variant="primary" navigate={~p"/dispos/new"}>
            <.icon name="hero-plus" /> New Dispo
          </.button>
        </:actions>
      </.header>

      <.table
        id="dispos"
        rows={@streams.dispos}
        row_click={fn {_id, dispo} -> JS.navigate(~p"/dispos/#{dispo}") end}
      >
        <:col :let={{_id, dispo}} label="Death">{dispo.death}</:col>
        <:col :let={{_id, dispo}} label="Latitude">{dispo.latitude}</:col>
        <:col :let={{_id, dispo}} label="Longitude">{dispo.longitude}</:col>
        <:col :let={{_id, dispo}} label="Location">{dispo.location}</:col>
        <:col :let={{_id, dispo}} label="Name">{dispo.name}</:col>
        <:col :let={{_id, dispo}} label="Is public">{dispo.is_public}</:col>
        <:col :let={{_id, dispo}} label="Password">{dispo.password}</:col>
        <:col :let={{_id, dispo}} label="Hashed password">{dispo.hashed_password}</:col>
        <:col :let={{_id, dispo}} label="Description">{dispo.description}</:col>
        <:action :let={{_id, dispo}}>
          <div class="sr-only">
            <.link navigate={~p"/dispos/#{dispo}"}>Show</.link>
          </div>
          <.link navigate={~p"/dispos/#{dispo}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, dispo}}>
          <.link
            phx-click={JS.push("delete", value: %{id: dispo.id}) |> hide("##{id}")}
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
      Dispos.subscribe_dispos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Dispos")
     |> stream(:dispos, Dispos.list_dispos(socket.assigns.current_scope))}
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
end
