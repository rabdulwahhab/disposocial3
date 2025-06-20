defmodule Disposocial3.Dispos do
  @moduledoc """
  The Dispos context.
  """

  import Ecto.Query, warn: false
  alias Disposocial3.Repo

  alias Disposocial3.Dispos.Dispo
  alias Disposocial3.Accounts.Scope
  alias Disposocial3.GlobalDispoMgr

  @radius_of_earth 3_959 # in miles (converted from 6_371 km)

  @doc """
  Subscribes to scoped notifications about any dispo changes.

  The broadcasted messages match the pattern:

    * {:created, %Dispo{}}
    * {:updated, %Dispo{}}
    * {:deleted, %Dispo{}}

  """
  def subscribe_dispos(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Disposocial3.PubSub, "user:#{key}:dispos")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Disposocial3.PubSub, "user:#{key}:dispos", message)
  end

  @doc """
  Returns the list of dispos.

  ## Examples

      iex> list_dispos(scope)
      [%Dispo{}, ...]

  """
  def list_dispos(%Scope{} = scope) do
    Repo.all(from dispo in Dispo, where: dispo.user_id == ^scope.user.id)
  end
  def list_dispos() do
    Repo.all(Dispo)
  end

  @doc """
  Gets a single dispo.

  Raises `Ecto.NoResultsError` if the Dispo does not exist.

  ## Examples

      iex> get_dispo!(123)
      %Dispo{}

      iex> get_dispo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dispo!(%Scope{} = scope, id) do
    Repo.get_by!(Dispo, id: id, user_id: scope.user.id)
  end
  def get_dispo(%Scope{} = scope, id), do: Repo.get_by(Dispo, id: id, user_id: scope.user.id)
  def get_dispo(id) do
    q = from(d in Dispo, where: d.id == ^id, preload: [:user])
    Repo.one(q)
  end

  def get_death_by_id(id) do
    q = from(d in Dispo, where: d.id == ^id, select: d.death)
    Repo.one(q)
  end

  @doc """
  Creates a dispo.

  ## Examples

      iex> create_dispo(%{field: value})
      {:ok, %Dispo{}}

      iex> create_dispo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dispo(%Scope{} = scope, %{"password" => password} = attrs) do
    raise "TODO"
  end
  def create_dispo(%Scope{} = scope, %{"duration" => duration} = attrs) do
    death_date =
      DateTime.utc_now()
      |> DateTime.add(String.to_integer(duration), :hour)

    new_attrs =
      Map.delete(attrs, "duration")
      |> Map.put("death", death_date)

    create_dispo(scope, new_attrs)
  end
  def create_dispo(%Scope{} = scope, attrs) do
    # Geoapify.get_location_by_coords(attrs["latitude"], attrs["longitude"])
    # Map.put(attrs, :location, geodata)
    with {:ok, dispo = %Dispo{}} <-
           %Dispo{}
           |> Dispo.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, dispo})
      {:ok, dispo}
    end
  end

  @doc """
  Updates a dispo.

  ## Examples

      iex> update_dispo(dispo, %{field: new_value})
      {:ok, %Dispo{}}

      iex> update_dispo(dispo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dispo(%Scope{} = scope, %Dispo{} = dispo, attrs) do
    true = dispo.user_id == scope.user.id

    with {:ok, dispo = %Dispo{}} <-
           dispo
           |> Dispo.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, dispo})
      {:ok, dispo}
    end
  end

  @doc """
  Deletes a dispo.

  ## Examples

      iex> delete_dispo(dispo)
      {:ok, %Dispo{}}

      iex> delete_dispo(dispo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dispo(%Dispo{} = dispo) do
    Repo.delete(dispo)
  end

  def delete_dispo!(%Dispo{} = dispo) do
    Repo.delete!(dispo)
  end

  def delete_dispo(%Scope{} = scope, %Dispo{} = dispo) do
    true = dispo.user_id == scope.user.id

    with {:ok, dispo = %Dispo{}} <-
           Repo.delete(dispo) do
      broadcast(scope, {:deleted, dispo})
      {:ok, dispo}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dispo changes.

  ## Examples

      iex> change_dispo(dispo)
      %Ecto.Changeset{data: %Dispo{}}

  """
  def change_dispo(%Scope{} = scope, %Dispo{} = dispo, attrs \\ %{}) do
    true = dispo.user_id == scope.user.id

    Dispo.changeset(dispo, attrs, scope)
  end

  def load_creator(dispo) do
    Repo.preload(dispo, [:user])
  end

  def exists?(id) do
    q = from d in Dispo, where: d.id == ^id
    Repo.exists?(q)
  end

  def get_name!(id) do
    q = from(d in Dispo, select: d.name)
    Repo.get!(q, id)
  end

  defp rad(deg) do
    deg * (:math.pi() / 180)
  end

  @doc """
  Calculates the Haversine distance between two points on Earth in feet.
  The Haversine distance is the distance between two points on a sphere.
  I use the accepted average radius of Earth (6,371 km) as the basis
  of conversion to US Customary feet.

  Adapted from a Python variation here:

  https://community.esri.com/t5/coordinate-reference-systems/distance-on-a-sphere-the-haversine-formula/ba-p/902128
  """
  def haversine_dist({lat1, lng1}, {lat2, lng2}) do
    phi_1 = rad(lat1)
    phi_2 = rad(lat2)
    delta_phi = rad(lat2 - lat1)
    delta_lam = rad(lng2 - lng1)
    a = :math.pow(:math.sin(delta_phi / 2), 2) + :math.cos(phi_1) * :math.cos(phi_2) * :math.pow(:math.sin(delta_lam / 2), 2)
    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @radius_of_earth * c
  end

  def haversine_dist_mi({lat1, lng1}, {lat2, lng2}) do
    haversine_dist({lat1, lng1}, {lat2, lng2}) / 5_280
  end

  @doc"""
  Gets the Dispos with coordinates within a radius of @dispo_radius.
  Uses Haversine distance calculation formula.

  NOTE: the Ecto query api (to my knowledge) will not allow conditionally
  selecting based on the haversine distance function so an initial query
  for nearby dispos is done to get plausible candidates before filtering
  for Dispos within the haversine distance.

  Here are two example geographic coordinates. IRL, the distance between them
  (in a direct line) is ~76.63 miles (hypotenuse). Using Driver, AR
  as a horizontal point (~67.29 miles West), I derive a latitude constant (L_x)
  which is multiplied by the @dispo_radius to give a rough latitudinal mile
  radius. The longitudinal constant (L_y) is derived similarly after
  calculating the delta in miles for the final (vertical) side using the
  Pythagorean theorem.

  Memphis: (35.149532, -90.048981)
  Jackson: (35.614517, -88.813950)

  L_x ~= 0.006910164958
  L_y ~= 0.03368556573

  As a safe bet, the initial query selects Dispos with latitudes of
  delta_lat_max = @lat_factor * @dispo_radius and longitudes of
  delta_lng_max = @lng_factor * @dispo_radius

  All calculations here use miles with coordinate degrees.
  """
  def get_all_near(qlat, qlng, radius) do
    # TODO lat and lng checking. fix this later
    query = cond do
      qlat > 0.0 && qlng > 0.0 -> from(d in Dispo, where: d.latitude > 0.0 and d.longitude > 0.0)
      qlat > 0.0 && qlng < 0.0 -> from(d in Dispo, where: d.latitude > 0.0 and d.longitude < 0.0)
      qlat < 0.0 && qlng > 0.0 -> from(d in Dispo, where: d.latitude < 0.0 and d.longitude > 0.0)
      qlat < 0.0 && qlng < 0.0 -> from(d in Dispo, where: d.latitude < 0.0 and d.longitude < 0.0)
      true -> nil
    end

    in_radius = fn(dispo) ->
      haversine_dist_mi({qlat, qlng}, {dispo.latitude, dispo.longitude}) <= radius end

    query
    |> Repo.all()
    |> Enum.filter(in_radius)
  end

  def get_global_dispo do
    {:ok, id} = GlobalDispoMgr.get_global_dispo_id()
    get_dispo(id)
  end

  def get_popular_posts(dispo_id) do
    from(d in Dispo,
      where: d.id == ^dispo_id,
      left_join: p in assoc(d, :posts),
      order_by: [desc: p.interactions],
      limit: 10,
      select: %{dispo: d, popular_posts: p}
    )
    |> Repo.all()
  end

  def present(dispo) do
    dispo
    |> Map.take([
        :id,
        :name,
        :location,
        :latitude,
        :longitude,
        :is_public,
        :inserted_at,
        :description,
        :death
        ])
  end

end
