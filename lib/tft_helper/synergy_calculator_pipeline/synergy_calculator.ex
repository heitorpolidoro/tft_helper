defmodule TftHelper.SynergyCalculatorPipeline.SynergyCalculator do
  @moduledoc false

  use GenStage

  def start() do
    GenStage.start(__MODULE__, nil, name: __MODULE__)
  end

  def stop() do
    GenStage.stop(__MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [TftHelper.SynergyCalculatorPipeline.SynergyGetter]}
  end

  def handle_events(comps, _from, state) do
    calculated_synergies =
      comps
      |> Enum.map(fn comp ->
        {comp, TftHelper.Managers.CompManager.calc_synergy(comp)}
      end)

    {:noreply, calculated_synergies, state}
  end
end
