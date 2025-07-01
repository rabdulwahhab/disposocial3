defmodule Disposocial3.GlobalDispoMgr do
  @moduledoc """
  The Global Dispo Manager will create a global Dispo every defined interval so that any
  user across the globe can join it.
  """

  use GenServer
  require Logger
  alias Disposocial3.{Dispos, DispoServer, Accounts, Accounts.User, Accounts.Scope, Repo}

  @global_dispo_user_email "global@disposocial.com"
  @global_dispo_user_params %User{
    username: "Disposocial",
    email: @global_dispo_user_email
  }
  # hours
  @global_dispo_duration 24
  @global_dispo_params %{
    "duration" => to_string(@global_dispo_duration),
    "name" => "Global Dispo",
    "description" =>
      "This Dispo is open to all users, no matter where in the world you are located. Welcome to Disposocial!",
    "location" => "All around the world",
    "latitude" => 0.0,
    "longitude" => 0.0
  }

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Logger.info("GlobalDispoMgr #{inspect(self())}: starting")
    # Create user (if not already) and scope
    global_user =
      with nil <- Accounts.get_user_by_email(@global_dispo_user_email),
           {:ok, user} <- Repo.insert(@global_dispo_user_params) do
        user
      end

    scope = Scope.for_user(global_user)

    if Accounts.get_num_user_dispos(global_user.id) > 0 do
      # Continue the Dispo from the DB
      [global_dispo] = Dispos.get_dispos_by_user(global_user.id)

      if DispoServer.start(global_dispo.id) == :ok do
        Logger.info("GlobalDispoMgr #{inspect(self())}: global Dispo resumed")
      end

      diff_seconds = DateTime.diff(global_dispo.death, DateTime.utc_now())
      # add small buffer to allow natural Dispo death before spinning up another global dispo
      Process.send_after(
        self(),
        {:create_global_dispo, scope},
        :timer.seconds(diff_seconds) + :timer.minutes(1)
      )

      {:ok, %{scope: scope, global_dispo: global_dispo}}
    else
      send(self(), {:create_global_dispo, scope})
      {:ok, %{scope: scope, global_dispo: nil}}
    end
  end

  @impl true
  def handle_info({:create_global_dispo, scope}, _) do
    # Create global dispo
    Logger.info(
      "GlobalDispoMgr #{inspect(self())}: creating global Dispo for (#{@global_dispo_duration} hours)"
    )

    dispo =
      with {:ok, dispo} <- Dispos.create_dispo(scope, @global_dispo_params),
           :ok <- DispoServer.start(dispo.id) do
        Logger.info("GlobalDispoMgr #{inspect(self())}: global Dispo started")
        dispo
      end

    # add small buffer to allow natural Dispo death before spinning up another global dispo
    Process.send_after(
      self(),
      {:create_global_dispo, scope},
      :timer.hours(@global_dispo_duration) + :timer.minutes(1)
    )

    {:noreply, %{scope: scope, global_dispo: dispo}}
  end

  def get_global_dispo_id do
    GenServer.call(__MODULE__, :get_global_dispo_id)
  end

  @impl true
  def handle_call(:get_global_dispo_id, _from, %{global_dispo: global_dispo} = state) do
    {:reply, {:ok, global_dispo.id}, state}
  end
end
