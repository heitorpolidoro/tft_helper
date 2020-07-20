defmodule TftHelperWeb.MainLive do
  use TftHelperWeb, :live_view

  import Ecto.Query

  alias TftHelper.Models.{Comp, Synergy}
  alias TftHelper.Managers.CompManager
  alias TftHelper.Repo

  @update_tick 100
  @total_comps CompManager.total_comps(8) + CompManager.total_comps(9) + CompManager.total_comps(10)


  @impl true
  def mount(_params, _session, socket) do
    send(self(), :update_info)
    {
      :ok,
      socket
      |> put_info
      |> assign(:stop, true)
    }
  end

  @impl true
  def handle_event("start", _params, socket) do
    CompManager.start_generation()
    send(self(), :update_info)
    {
      :noreply,
      socket
      |> assign(:stop, false)
    }
  end

  @impl true
  def handle_event("stop", _params, socket) do
    CompManager.stop_generation()
    {
      :noreply,
      socket
      |> assign(:stop, true)
    }
  end

  @impl true
  def handle_info(:update_info, socket) do
    :timer.send_after(@update_tick, self(), :update_info)
    #    unless socket.assigns.stop, do: :timer.send_after(@update_tick, self(), :update_info)
    { :noreply, put_info(socket) }
  end

  def put_info(socket) do

    total_comps_saved = Repo.one(from c in Comp, select: count(c))
    total_synergies_saved = Repo.one(from c in Synergy, select: count(c))

    remaining_comps = @total_comps - total_comps_saved
    stop =
      if Map.has_key?(socket.assigns, :total_comps_saved) do
        socket.assigns.total_comps_saved == total_comps_saved or
        socket.assigns.total_synergy_saved == total_synergies_saved
      else
        true
      end

    {comps_eta_value, comps_eta_unity, comps_per_ms_list} =
      if Map.has_key?(socket.assigns, :remaining_comps) do
        comps_per_ms = (socket.assigns.remaining_comps - remaining_comps) / @update_tick
        comps_per_ms_list = Enum.take(socket.assigns.comps_per_ms_list ++ [comps_per_ms], -100)
        comps_per_ms_avg = Enum.reduce(comps_per_ms_list, fn (score, sum) -> sum + score end) + 0.1
        comps_eta_ms = remaining_comps / comps_per_ms_avg
        {value, unity} = ms_to_human(comps_eta_ms)
        {value, unity, comps_per_ms_list}
      else
        {"-", "", []}
      end

    remaining_synergies = total_comps_saved - total_synergies_saved

    {synergies_eta_value, synergies_eta_unity, synergies_per_ms_list} =
      if Map.has_key?(socket.assigns, :remaining_synergies) do
        synergies_per_ms = (socket.assigns.remaining_synergies - remaining_synergies) / @update_tick
        synergies_per_ms_list = Enum.take(socket.assigns.synergies_per_ms_list ++ [synergies_per_ms], -100)
        synergies_per_ms_avg = Enum.reduce(synergies_per_ms_list, fn (score, sum) -> sum + score end) + 0.1
        if synergies_per_ms_avg > 0 do
          synergies_eta_ms = remaining_synergies / synergies_per_ms_avg
          {value, unity} = ms_to_human(synergies_eta_ms)
          {value, unity, synergies_per_ms_list}
        else
          {"-", "", []}
        end
      else
        {"-", "", []}
      end

    socket
    |> assign(:total_comps_saved, total_comps_saved)
    |> assign(:remaining_comps, remaining_comps)
    |> assign(:comps_eta_value, comps_eta_value)
    |> assign(:comps_eta_unity, comps_eta_unity)
    |> assign(:comps_per_ms_list, comps_per_ms_list)
    |> assign(:total_synergies_saved, total_synergies_saved)
    |> assign(:remaining_synergies, remaining_synergies)
    |> assign(:synergies_eta_value, synergies_eta_value)
    |> assign(:synergies_eta_unity, synergies_eta_unity)
    |> assign(:synergies_per_ms_list, synergies_per_ms_list)
    |> assign(:remaining_synergies, total_comps_saved - total_synergies_saved)
    |> assign(:stop, stop)
  end

  def ms_to_human(value, unity \\ "milliseconds", to_next_unity \\ 1000) do
    next_unity_map = %{
      "milliseconds" => {"seconds", 60},
      "seconds" => {"minutes", 60},
      "minutes" => {"hours", 24},
      "hours" => {"days", 30},
      "days" => {"months", 12},
      "months" => {"years", nil}
    }
    if unity != "years" and value >= to_next_unity do
      {new_unity, new_to_next_unity} = next_unity_map[unity]
      ms_to_human(value / to_next_unity, new_unity, new_to_next_unity)
    else
      {Float.round(value, 2), unity}
    end
  end

end
