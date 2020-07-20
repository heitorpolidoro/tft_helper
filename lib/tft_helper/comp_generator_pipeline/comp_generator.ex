defmodule TftHelper.CompGeneratorPipeline.CompGenerator do
  @moduledoc false
  import Ecto.Query

  use GenStage

  alias TftHelper.Managers.CompManager
  alias TftHelper.Models.Comp
  alias TftHelper.Repo

  def start(size) do
    initial =
      0..(size - 1)
      |>Enum.map(fn i -> i end)
      |> Enum.reverse

    initial =
      initial
      |> List.replace_at(0, Enum.at(initial, 0) - 1)

    initial_comp =
      CompManager.comp_str_to_list(
        Repo.one(from c in Comp, limit: 1, where: c.size == ^size, select: c.comp, order_by: [desc: c.id])) || initial

    GenStage.start(__MODULE__, initial_comp, name: String.to_atom("#{__MODULE__}#{size}"))
  end

  def stop(size) do
    GenStage.stop(String.to_atom("#{__MODULE__}#{size}"))
  end

  def init(counter), do: {:producer, counter}

  def handle_demand(demand, state) do
    {list, last} =
      1..demand
      |> Enum.reduce({[], state}, fn _i, {list, last} ->
        new_comp = CompManager.get_next_comp(last)
        {
          Enum.filter(list ++ [new_comp], &!is_nil(&1)),
          new_comp
        }
      end)

    {:noreply, list, last}
  end
end
