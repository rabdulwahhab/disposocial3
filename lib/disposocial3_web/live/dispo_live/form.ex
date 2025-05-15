defmodule Disposocial3Web.DispoLive.Form do
  use Disposocial3Web, :live_view

  alias Disposocial3.Dispos
  alias Disposocial3.Dispos.Dispo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage dispo records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="dispo-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:death]} type="datetime-local" label="Death" />
        <.input field={@form[:latitude]} type="number" label="Latitude" step="any" />
        <.input field={@form[:longitude]} type="number" label="Longitude" step="any" />
        <.input field={@form[:location]} type="text" label="Location" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:is_public]} type="checkbox" label="Is public" />
        <.input field={@form[:password]} type="text" label="Password" />
        <.input field={@form[:hashed_password]} type="text" label="Hashed password" />
        <.input field={@form[:description]} type="text" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Dispo</.button>
          <.button navigate={return_path(@current_scope, @return_to, @dispo)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    dispo = Dispos.get_dispo!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Dispo")
    |> assign(:dispo, dispo)
    |> assign(:form, to_form(Dispos.change_dispo(socket.assigns.current_scope, dispo)))
  end

  defp apply_action(socket, :new, _params) do
    dispo = %Dispo{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Dispo")
    |> assign(:dispo, dispo)
    |> assign(:form, to_form(Dispos.change_dispo(socket.assigns.current_scope, dispo)))
  end

  @impl true
  def handle_event("validate", %{"dispo" => dispo_params}, socket) do
    changeset = Dispos.change_dispo(socket.assigns.current_scope, socket.assigns.dispo, dispo_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"dispo" => dispo_params}, socket) do
    save_dispo(socket, socket.assigns.live_action, dispo_params)
  end

  defp save_dispo(socket, :edit, dispo_params) do
    case Dispos.update_dispo(socket.assigns.current_scope, socket.assigns.dispo, dispo_params) do
      {:ok, dispo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Dispo updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, dispo)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_dispo(socket, :new, dispo_params) do
    case Dispos.create_dispo(socket.assigns.current_scope, dispo_params) do
      {:ok, dispo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Dispo created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, dispo)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _dispo), do: ~p"/discover"
  defp return_path(_scope, "show", dispo), do: ~p"/dispos/#{dispo}"
end
