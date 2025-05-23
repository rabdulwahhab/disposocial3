defmodule Disposocial3Web.PostLive.Form do
  use Disposocial3Web, :live_component

  alias Disposocial3.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="sticky bottom-0">
      <.form for={@form} id="post-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="flex flex-row justify-center gap-2">
          <div class="basis-sm">
            <.input field={@form[:body]} type="textarea" placeholder="Your message here" phx-hook="EnterToSubmit" />
          </div>
          <div>
            <.button phx-disable-with="Saving..." variant="primary" disabled={not @form.source.valid?} class="btn-xl">
              <.icon name="hero-paper-airplane" class="size-5" />
            </.button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(:live_action, :new)
      |> then(fn socket_sofar -> reset_form(socket_sofar) end)}
  end

  defp blank_post_changeset(current_scope) do
    blank_post =
      %Posts.Post{
        user_id: current_scope.user.id,
        dispo_id: current_scope.dispo.id
      }
    Posts.change_post(current_scope, blank_post)
  end

  defp reset_form(socket) do
    assign(socket, :form, to_form(blank_post_changeset(socket.assigns.current_scope)))
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset = Posts.change_post(socket.assigns.current_scope, socket.assigns.form.data, post_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    final_post_params = post_params |> Map.put("dispo_id", socket.assigns.current_scope.dispo.id)
    save_post(socket, socket.assigns.live_action, final_post_params)
  end

  defp save_post(socket, :new, post_params) do
    case Posts.create_post(socket.assigns.current_scope, post_params) do
      {:ok, post} ->
        notify_parent({:new_post, post})
        {:noreply, reset_form(socket)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # defp save_post(socket, :edit, post_params) do
  #   case Posts.update_post(socket.assigns.current_scope, socket.assigns.post, post_params) do
  #     {:ok, post} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Post updated successfully")
  #        |> push_navigate(
  #          to: return_path(socket.assigns.current_scope, socket.assigns.return_to, post)
  #        )}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, form: to_form(changeset))}
  #   end
  # end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

end
