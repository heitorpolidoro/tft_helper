defmodule TftHelper.CompGeneratorPipeline.CompValidator do
  @moduledoc false

  use GenStage

  def start(size) do
    GenStage.start(__MODULE__, size, name: String.to_atom("#{__MODULE__}#{size}"))
  end

  def stop(size) do
    GenStage.stop(String.to_atom("#{__MODULE__}#{size}"))
  end

  def init(size) do
    {:producer_consumer, size, subscribe_to: [String.to_atom("#{TftHelper.CompGeneratorPipeline.CompGenerator}#{size}")]}
  end

  def handle_events(comps, _from, state) do
    valid_comps =
      comps
      |> Enum.filter(fn comp ->
        length(Enum.uniq(comp)) == length(comp) and # Rejecting comps with duplicated values
        Enum.reverse(Enum.sort(comp)) == comp # Rejecting not sorted comps
      end)

    {:noreply, valid_comps, state}
  end
end
