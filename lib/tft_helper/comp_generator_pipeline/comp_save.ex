defmodule TftHelper.CompGeneratorPipeline.CompSave do
  @moduledoc false

  use GenStage

  alias TftHelper.Managers.CompManager

  def start(size, index \\ 0) do
    GenStage.start(__MODULE__, size, name: String.to_atom("#{__MODULE__}#{size}_#{index}"))
  end

  def stop(size, index \\ 0) do
    GenStage.stop(String.to_atom("#{__MODULE__}#{size}_#{index}"))
  end

  def init(size) do
    {:consumer, size, subscribe_to: [String.to_atom("#{TftHelper.CompGeneratorPipeline.CompValidator}#{size}")]}
  end

  def handle_events(comps, _from, state) do
    comps
    |> Enum.each(&CompManager.create_comp(&1))

    {:noreply, [], state}
  end
end
