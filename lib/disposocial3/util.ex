defmodule Disposocial3.Util do
  @moduledoc """
  Contains various utility functions used throughout the app.
  """

  def display_relative_time(datetime) do
    now = DateTime.utc_now()
    minutes_left = DateTime.diff(datetime, now, :minute)
    cond do
      minutes_left > 0 and minutes_left > 60 -> "#{div(minutes_left, 60)} hour(s) and #{rem(minutes_left, 60)} minute(s) left"
      minutes_left > 0 -> "#{minutes_left} minute(s) left"
      minutes_left < 0 and abs(minutes_left) > 60 -> "#{div(abs(minutes_left), 60)} hour(s) and #{rem(abs(minutes_left), 60)} minute(s) ago"
      minutes_left < 0 -> "#{abs(minutes_left)} minute(s) ago"
      true -> "#{DateTime.diff(datetime, now, :second)} second(s) ago"
    end
  end
end
