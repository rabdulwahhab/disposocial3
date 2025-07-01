defmodule Disposocial3.Geoapify do
  @api_base "https://api.geoapify.com/v1"

  def reverse_geocode(lat, lng) do
    api_key = Application.get_env(:disposocial3, Disposocial3.Geoapify)[:api_key]
    auth_str = "apiKey=#{api_key}"
    params_str = "lat=#{to_string(lat)}&lon=#{to_string(lng)}"
    url = "#{Path.join(@api_base, "/geocode/reverse")}?#{params_str}&#{auth_str}"
    task = Task.async(fn -> Req.get(url) end)

    clean = fn data -> List.first(data["features"])["properties"] end

    case Task.await(task) do
      {:ok, response} -> {:ok, clean.(response.body)}
      any -> any
    end
  end

  def format_location(geodata) do
    "#{geodata["street"]} - #{geodata["city"]}, #{geodata["state"]} #{String.upcase(geodata["country_code"])}"
  end
end
