defmodule TftHelper.SynergyCalculatorPipeline.SynergyGetter do
  @moduledoc false
  import Ecto.Query

  use GenStage

  alias TftHelper.Models.Comp
  alias TftHelper.Repo

  def start() do
    GenStage.start(__MODULE__, nil, name: __MODULE__)
  end

  def stop() do
    GenStage.stop(__MODULE__)
  end

  def init(counter), do: {:producer, counter}

  def handle_demand(demand, state) do
    synergies = Repo.all(from c in Comp, where: is_nil(c.synergy_id), limit: ^demand)
    if Enum.empty?(synergies) do
      IO.puts("sleeping")
      :timer.sleep(1000)
      handle_demand(demand, state)
    else
      {:noreply, synergies, state}
    end

  end
end
