defmodule TftHelper.SynergyCalculatorPipeline.SynergySave do
  @moduledoc false

  use GenStage

  alias TftHelper.Managers.CompManager

  def start(index \\ 0) do
    GenStage.start(__MODULE__, :state_doesnt_matter, name: String.to_atom("#{__MODULE__}#{index}"))
  end

  def stop(index \\ 0) do
    GenStage.stop(String.to_atom("#{__MODULE__}#{index}"))
  end

  def init(state) do
    {:consumer, state, subscribe_to: [TftHelper.SynergyCalculatorPipeline.SynergyCalculator]}
  end

  def handle_events(comp_synergy, _from, state) do
    comp_synergy
    |> Enum.each(fn {comp, synergy} ->
      {:ok, saved_synergy} = CompManager.create_synergy(synergy)

      CompManager.update_comp(comp, saved_synergy)
    end)

    {:noreply, [], state}
  end
end
