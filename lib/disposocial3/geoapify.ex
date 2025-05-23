defmodule Disposocial3.Geoapify do
  @api_base "https://api.geoapify.com/v1"

  # def get_location_by_coords(lat, lng) do
  #   raise "FIXME"
  #   geo_api_key = Application.get_env(:Disposocial3, :geo_api_key)
  #   # TODO from here down
  #   access_str = "apiKey=#{geo_api_key}"
  #   latlong_str = "lat=#{to_string(lat)}&lon=#{to_string(lng)}"
  #   url = "#{Path.join(@api_base, "/geocode/reverse")}?#{latlong_str}&#{access_str}"
  #   resp = HTTPoison.get!(url)
  #   IO.inspect(resp, label: "Geocode API response:")
  #   raise "TODO"
  #   # data =
  #   #   resp
  #   #   |> Map.get(:body)
  #   #   |> Jason.decode!()
  #   #   |> Map.get("data")

  #   # TODO
  # end

end
