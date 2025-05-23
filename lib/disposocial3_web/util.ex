defmodule Disposocial3Web.Util do
  @moduledoc """
  Contains various utility functions used throughout the app.
  """

  def display_relative_time_future(datetime) do
    now = DateTime.utc_now()
    minutes_left = DateTime.diff(datetime, now, :minute)
    cond do
      minutes_left > 0 and minutes_left > 60 -> "#{div(minutes_left, 60)} hour(s) and #{rem(minutes_left, 60)} minute(s) left"
      minutes_left > 0 -> "#{minutes_left} minute(s) left"
      true -> "#{abs(DateTime.diff(datetime, now, :second))} second(s) left"
    end
  end

  def display_relative_time_past(datetime) do
    now = DateTime.utc_now()
    minutes_left = DateTime.diff(datetime, now, :minute)
    cond do
      minutes_left < 0 and abs(minutes_left) > 60 -> "#{div(abs(minutes_left), 60)} hour(s) and #{rem(abs(minutes_left), 60)} minute(s) ago"
      minutes_left < 0 -> "#{abs(minutes_left)} minute(s) ago"
      true -> "#{abs(DateTime.diff(datetime, now, :second))} second(s) ago"
    end
  end

  def display_post_time(datetime) do
    cond do
      today?(datetime) -> Calendar.strftime(datetime, "%I:%M%p")
      true -> Calendar.strftime(datetime, "%a %I:%M%p")
    end
  end

  def display_death_datetime(datetime) do
    Calendar.strftime(datetime, "%a %b %d @ %I:%M%p")
  end

  defp today?(dt) do
    today = DateTime.utc_now()
    {dt.month, dt.day, dt.year} == {today.month, today.day, today.year}
  end
end
