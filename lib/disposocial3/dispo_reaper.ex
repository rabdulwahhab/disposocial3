defmodule Disposocial3.DispoReaper do
  use Task
  import Ecto.Query
  require Logger
  alias Disposocial3.{Repo, Dispos, Dispos.Dispo, Accounts.User, Accounts.Scope}

  @cleanup_interval 24  # hours

  def start_link(_opts) do
    Task.start_link(&loop/0)
  end

  defp loop do
    Logger.info("DispoReaper #{inspect(self())}: sleep (#{@cleanup_interval} hours)")
    Process.sleep(:timer.hours(@cleanup_interval))
    Logger.info("DispoReaper: awake")
    reap_dispos()
    loop()
  end

  defp reap_dispos do
    now = DateTime.utc_now()
    q = from(d in Dispo, where: d.death < ^now)
    zombie_dispos = Repo.all(q)
    if zombie_dispos == [] do
      Logger.info("DispoReaper: nothing to do")
    else
      Enum.each(zombie_dispos, fn dispo -> Dispos.delete_dispo!(dispo) end)
      Logger.info("DispoReaper: cleaned up #{length(zombie_dispos)} Dispo(s)")
    end
  end

end
