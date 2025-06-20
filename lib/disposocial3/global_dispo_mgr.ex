defmodule Disposocial3.GlobalDispoMgr do
  @moduledoc """
  The Global Dispo Manager will create a global Dispo every defined interval so that any
  user across the globe can join it.
  """

  use GenServer
  require Logger
  alias Disposocial3.{Dispos, DispoServer, Accounts.User, Accounts.Scope, Repo}

  @global_dispo_user_params %User{
    username: "Global Dispo",
    email: "global@global.com"
  }
  @global_dispo_duration 24  # hours
  @global_dispo_params %{
    "duration" => to_string(@global_dispo_duration),
    "name" => "Global Dispo",
    "description" => "This Dispo is open to all users, no matter where in the world you are located. Welcome to Disposocial!",
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
    scope =
      with {:ok, user} <- Repo.insert(@global_dispo_user_params, on_conflict: :nothing) do
        Scope.for_user(user)
      end

    send(self(), {:create_global_dispo, scope})
    {:ok, %{}}
  end

  @impl true
  def handle_info({:create_global_dispo, scope}, _) do
    # Create global dispo
    Logger.info("GlobalDispoMgr #{inspect(self())}: creating global Dispo for (#{@global_dispo_duration} hours)")
    dispo =
      with {:ok, dispo} <- Dispos.create_dispo(scope, @global_dispo_params),
            :ok <- DispoServer.start(dispo.id) do
        Logger.info("GlobalDispoMgr #{inspect(self())}: global Dispo started")
        dispo
      end

    Process.send_after(self(), {:create_global_dispo, scope}, :timer.hours(@global_dispo_duration) + :timer.minutes(1))  # add small buffer to allow natural Dispo death before spinning up another global dispo
    {:noreply, %{scope: scope, global_dispo: dispo}}
  end

  def get_global_dispo_id do
    GenServer.call(__MODULE__, :get_global_dispo_id)
  end

  @impl true
  def handle_call(:get_global_dispo_id, _from, %{global_dispo: dispo} = state) do
    {:reply, {:ok, dispo.id}, state}
  end

end
