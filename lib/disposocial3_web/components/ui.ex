defmodule Disposocial3Web.UI do
  @moduledoc """
  This module holds my various, custom UI used throughout the application.

  See the `ui` directory for all components available.
  """
  use Disposocial3Web, :html

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
end
