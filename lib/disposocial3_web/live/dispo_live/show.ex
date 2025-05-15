defmodule Disposocial3Web.DispoLive.Show do
  use Disposocial3Web, :live_view

  alias Disposocial3.Dispos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Dispo {@dispo.id}
        <:subtitle>This is a dispo record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/discover"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/dispos/#{@dispo}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit dispo
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Death">{@dispo.death}</:item>
        <:item title="Latitude">{@dispo.latitude}</:item>
        <:item title="Longitude">{@dispo.longitude}</:item>
        <:item title="Location">{@dispo.location}</:item>
        <:item title="Name">{@dispo.name}</:item>
        <:item title="Is public">{@dispo.is_public}</:item>
        <:item title="Password">{@dispo.password}</:item>
        <:item title="Hashed password">{@dispo.hashed_password}</:item>
        <:item title="Description">{@dispo.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Dispos.subscribe_dispos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Dispo")
     |> assign(:dispo, Dispos.get_dispo!(socket.assigns.current_scope, id))}
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
     |> put_flash(:error, "The current dispo was deleted.")
     |> push_navigate(to: ~p"/discover")}
  end

  def handle_info({type, %Disposocial3.Dispos.Dispo{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
