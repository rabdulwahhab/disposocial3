defmodule Disposocial3Web.UI do
  @moduledoc """
  This module holds my various, custom UI used throughout the application.

  See the `ui` directory for all components available.
  """
  use Disposocial3Web, :html

  alias Disposocial3.Util
  embed_templates "ui/*"

  def hero(assigns) do
    ~H"""
    <div class="hero bg-base-200 h-80 mt-30 rounded-md">
      <div class="hero-content text-center">
        <div class="max-w-md">
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
        <%= if @dispo.is_public do %>
        <span class="badge badge-xs badge-info">Public</span>
        <% else %>
        <span class="badge badge-xs badge-info">Private</span>
        <% end %>
        <span class="badge badge-xs badge-success">Online: {@dispo.active_users}</span>
        <div class="flex justify-between">
          <h2 class="text-3xl font-bold">{@dispo.name}</h2>
          <span class="text-xl">{"#{@dispo.latitude}, #{@dispo.longitude}"}</span>
        </div>
        {@dispo.description}
        <ul class="mt-6 flex flex-col gap-2 text-xs">
          <li>
            <span>{"Created: #{Util.display_relative_time(@dispo.inserted_at)}"}</span>
          </li>
          <li>
            <span class="text-error-content">{"Expiration: #{Util.display_relative_time(@dispo.death)}"}</span>
          </li>
        </ul>
        <div class="mt-6">
          <.button :if={@dispo.is_public} navigate={~p"/dispos/#{@dispo.id}"} class="btn-primary btn-block">Join</.button>
        </div>
      </div>
    </div>
    """
  end
end
