defmodule Disposocial3Web.DispoLive.Form do
  use Disposocial3Web, :live_view

  alias Disposocial3.{Dispos, Dispos.Dispo, DispoServer}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.container flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage dispo records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="dispo-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <.input
            field={@form[:duration]}
            type="select"
            label="Duration (hours)"
            options={[1, 2, 5, 8, 24, 48, 72]}
          />
          <%!-- <.input field={@form[:is_public]} type="checkbox" label="Is public" />
        <.input field={@form[:password]} type="text" label="Password" /> --%>
          <footer>
            <.button phx-disable-with="..." variant="primary">Save Dispo</.button>
            <.button navigate={return_path(@current_scope, @return_to, @dispo)} class="btn-ghost">
              Cancel
            </.button>
          </footer>
        </.form>
      </div>
    </Layouts.container>
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
    |> assign(:page_title, "Create Dispo")
    |> assign(:dispo, dispo)
    |> assign(:form, to_form(Dispos.change_dispo(socket.assigns.current_scope, dispo)))
  end

  @impl true
  def handle_event("validate", %{"dispo" => dispo_params}, socket) do
    changeset =
      Dispos.change_dispo(socket.assigns.current_scope, socket.assigns.dispo, dispo_params)

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
    user_location = %{
      "latitude" => socket.assigns.current_scope.user.latitude,
      "longitude" => socket.assigns.current_scope.user.longitude
    }

    final_dispo_params = Map.merge(dispo_params, user_location)

    with {:ok, dispo} <- Dispos.create_dispo(socket.assigns.current_scope, final_dispo_params),
         :ok <- DispoServer.start(dispo.id) do
      {:noreply,
       socket
       |> put_flash(:info, "Dispo created successfully")
       |> push_navigate(
         to: return_path(socket.assigns.current_scope, socket.assigns.return_to, dispo)
       )}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      :error ->
        {:noreply, put_flash(socket, :error, "Failed starting the Dispo server")}
    end
  end

  defp return_path(_scope, "index", _dispo), do: ~p"/discover"
  defp return_path(_scope, "show", dispo), do: ~p"/dispos/#{dispo}"
end
