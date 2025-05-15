defmodule Disposocial3.DispoServer do
  use GenServer

  require Logger
  alias Disposocial3Web.Endpoint
  alias Disposocial3.{DispoState, Dispos, Posts, DispoRegistry, DispoSupervisor, Comments, Reactions, Accounts.Scope}

  defp registry(id) do
    {:via, Registry, {DispoRegistry, id}}
  end

  defp dispo_topic(dispo_id) do
    "dispo:#{dispo_id}"
  end

  defp scope, do: Scope.for_root(__MODULE__)

  # API

  def start(id) do
    # Start a new DispoServer Process and get it supervised
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [id]},
      restart: :transient
    }

    case DispoSupervisor.start_child(spec) do
      {:ok, _} ->
        Logger.info("Started DispoServer for Dispo id = #{id}")
        :ok
      {:ok, _, _} ->
        Logger.info("Started DispoServer for Dispo id = #{id}")
        :ok
      other ->
        Logger.error("Failed starting DispoServer for Dispo id = #{id}: #{inspect(other)}")
        :error
    end
  end

  def peek(id) when is_integer(id), do: GenServer.call(registry(id), :peek)
  def peek(pid) when is_pid(pid), do: GenServer.call(pid, :peek)
  def get_dispo(id) when is_integer(id), do: GenServer.call(registry(id), :get_dispo)
  def get_dispo(pid) when is_pid(pid), do: GenServer.call(pid, :get_dispo)
  def get_post(id, post_id) when is_integer(id), do: GenServer.call(registry(id), {:get_post, post_id})
  def get_post(pid, post_id) when is_pid(pid), do: GenServer.call(pid, {:get_post, post_id})
  def get_posts(id, post_ids) when is_integer(id), do: GenServer.call(registry(id), {:get_posts, post_ids})
  def get_posts(pid, post_ids) when is_pid(pid), do: GenServer.call(pid, {:get_posts, post_ids})
  def get_recent_posts(id) when is_integer(id), do: GenServer.call(registry(id), :get_recent_posts)
  def get_recent_posts(pid) when is_pid(pid), do: GenServer.call(pid, :get_recent_posts)
  def get_popular_posts(id) when is_integer(id), do: GenServer.call(registry(id), :get_popular_posts)
  def get_popular_posts(pid) when is_pid(pid), do: GenServer.call(pid, :get_popular_posts)
  def get_recent_comments(id) when is_integer(id), do: GenServer.call(registry(id), :get_recent_comments)
  def get_recent_comments(pid) when is_pid(pid), do: GenServer.call(pid, :get_recent_comments)
  def get_recent_reactions(id) when is_integer(id), do: GenServer.call(registry(id), :get_recent_reactions)
  def get_recent_reactions(pid) when is_pid(pid), do: GenServer.call(pid, :get_recent_reactions)
  # NOTE maybe none of these need to be GenServer calls.
  # Could maybe get away with casting and then broadcast
  # and may provide channels to handle more load since they
  # dont have to wait for DispoServer to respond with
  # appropriate data which is downtime due to DB calls.
  # Try this out
  def post_post(id, attrs) when is_integer(id), do: GenServer.call(registry(id), {:post_post, attrs})
  def post_post(pid, attrs) when is_pid(pid), do: GenServer.call(pid, {:post_post, attrs})
  def post_comment(id, attrs) when is_integer(id), do: GenServer.call(registry(id), {:post_comment, attrs})
  def post_comment(pid, attrs) when is_pid(pid), do: GenServer.call(pid, {:post_comment, attrs})
  def post_reaction(id, attrs) when is_integer(id), do: GenServer.call(registry(id), {:post_reaction, attrs})
  def post_reaction(pid, attrs) when is_pid(pid), do: GenServer.call(pid, {:post_reaction, attrs})

  # def broadcast_feed(id) do
  #   GenServer.cast(registry(id), :broadcast_feed)
  # end

  # Helpers

  # Callbacks

  def start_link(id) do
    # Starts the Process instance and calls init
    GenServer.start_link(__MODULE__, id, name: registry(id))
  end

  @impl true
  def init(id) do
    # REQUIRED: This is invoked when the GenServer process is started and is
    # called by `start_link`. It is the DispoServer entrypoint. Blocking until it returns.
    # 1. Get the Dispo metadata by id
    # 2. Init self-destruct time
    # 3. Init next remaining time reminder
    Logger.info("Starting DispoServer #{inspect(self())} for Dispo id = #{id}")

    if dispo = Dispos.get_dispo(id) do
      remove_fields = [:user, :posts, :__meta__]
      init_state =
        dispo
        |> Map.from_struct()
        |> Map.drop(remove_fields)
      case init_death(dispo) do
        :ok -> Logger.info("Initialized DispoServer #{inspect(self())} (#{dispo.name}:#{dispo.id})")
              {:ok, init_state}
        {:error, msg} -> {:stop, msg}
      end
    else
      {:stop, "No Dispo with id '#{id}' found"}
    end
  end

  defp init_death(dispo) do
    # send self destruct message in on death date in the future
    seconds_left = DateTime.diff(dispo.death, DateTime.utc_now())
    if seconds_left <= 0 do
      {:error, "Cannot init Dispo with death date in the past: #{dispo.death}"}
    else
      # Init death notification
      Process.send_after(self(), :death, seconds_left * 1000)
      # Init next death reminder notification
      next_reminder = round(seconds_left / 2)
      if next_reminder > 10 do  # stop exponential backoff reminders at 10 seconds left
        Process.send_after(self(), :death_reminder, next_reminder * 1000)
      end
      :ok
    end
  end

  @impl true
  def handle_call(:peek, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_dispo, _from, state) do
    {:reply, Dispos.present(state), state}
  end

  @impl true
  def handle_call({:get_post, post_id}, _from, state) do
    post = Posts.get_post(state.id, post_id)
    {:reply, post, state}
  end

  @impl true
  def handle_call({:get_posts, post_ids}, _from, state) do
    posts = Posts.get_posts(state.id, post_ids)
    {:reply, posts, state}
  end

  @impl true
  def handle_call(:get_recent_posts, _from, state) do
    posts = Posts.recent_posts(state.id)
    {:reply, posts, state}
  end

  @impl true
  def handle_call(:get_recent_comments, _from, state) do
    post_ids = Posts.recent_post_ids(state.id)
    comms =
      for post_id <- post_ids, into: %{} do
        {post_id, Comments.get_post_comments(post_id)}
      end
      |> Enum.reject(fn {_, v} -> v == [] end)
      |> Enum.into(%{})

    {:reply, comms, state}
  end

  @impl true
  def handle_call(:get_recent_reactions, _from, state) do
    post_ids = Posts.recent_post_ids(state.id)
    reactions =
      for post_id <- post_ids, into: %{} do
        {post_id, Posts.get_reaction_counts(post_id)}
      end

    {:reply, reactions, state}
  end

  @impl true
  def handle_call(:get_popular_posts, _from, state) do
    # Sort popular and return array
    {:reply, state.popular, state}
  end

  @impl true
  def handle_call({:post_post, attrs}, _from, state) do
    case Posts.create_post(attrs) do
      {:ok, post} -> {:reply, {:ok, Posts.present(post)}, state}
      {:error, chgset} -> {:reply, {:error, chgset}, state}
    end
  end

  @impl true
  def handle_call({:post_comment, attrs}, _from, state) do
    case Comments.create_comment(attrs) do
      {:ok, comment} ->
        send(self(), {:count_popular, attrs.post_id})
        {:reply, {:ok, Comments.present(comment)}, state}
      {:error, chgset} -> {:reply, {:error, chgset}, state}
    end
  end

  @impl true
  def handle_call({:post_reaction, attrs}, _from, state) do
    case Reactions.create_or_update_reaction(attrs) do
      {:ok, :created} ->
        send(self(), {:count_popular, attrs.post_id})
        {:reply, :created, state}
      {:ok, :updated} -> {:reply, :updated, state}
      :noop -> {:reply, :noop, state}
    end
  end

  # @impl true
  # def handle_cast(:broadcast_feed, state) do
  #   # TODO broadcast on channel topic (dispo)
  #   {:noreply, state}
  # end

  @doc"""
  Calculates what the most popular posts are for the dispo
  """
  @impl true
  def handle_info({:count_popular, post_id}, state) do
    # count reactions + comments for the post
    # store in state if popular less than 10 or beats another in popularity
    num_interactions = Posts.get_interaction_count(post_id)
    state = DispoState.compute_popular(post_id, num_interactions, state)
    Logger.debug("Counted popular state --> #{inspect(state)}")
    {:noreply, state}
  end

  # Exponential backoff reminders of termination date.
  @impl true
  def handle_info(:death_reminder, %{death: death_datetime, id: dispo_id, name: dispo_name} = state) do
    seconds_left = DateTime.diff(death_datetime, DateTime.utc_now())
    # Init time remaining reminder
    next_reminder = round(seconds_left / 2)
    if next_reminder > 10 do  # stop exponential backoff reminders at 10 seconds left
      Logger.notice("DispoServer #{inspect(self())} (#{dispo_name}:#{dispo_id}) broadcasting reminder: #{seconds_left} secs left")
      Endpoint.broadcast_from(self(), dispo_topic(dispo_id), "death_reminder", %{seconds_left: seconds_left})
      Process.send_after(self(), :death_reminder, next_reminder * 1000)
    end
    {:noreply, state}
  end

  @impl true
  def handle_info(:death, %{id: dispo_id, name: dispo_name} = state) do
    # self destruct
    Endpoint.broadcast_from(self(), dispo_topic(dispo_id), "angel_of_death", %{})
    Process.sleep(2_000)  # minimal sleep to let all connected users disconnect
    dispo = Dispos.get_dispo!(dispo_id)
    {:ok, _} = Dispos.delete_dispo(dispo)
    Logger.notice("Dispo #{dispo_name}(#{dispo_id}) deleted. Shutting down associated DispoServer")
    # Goodbye
    {:stop, :normal, state}
  end

  @impl true
  def terminate(:normal, %{id: dispo_id, name: dispo_name} = _state) do
    # The final stand
    Logger.info("DispoServer #{inspect(self())} (#{dispo_name}:#{dispo_id}) died peacefully")
  end

  @impl true
  def terminate({reason, _}, %{id: dispo_id, name: dispo_name} = state) do
    Logger.critical("DispoServer #{inspect(self())} (#{dispo_name}:#{dispo_id}) terminated abnormally (#{inspect(reason)}) with state --> #{inspect(state)}")
  end

end
