defmodule TftHelper.Managers.CompManager do
  @moduledoc false
  import Ecto.Query

  alias TftHelper.CompGeneratorPipeline.{CompGenerator, CompValidator, CompSave}
  alias TftHelper.SynergyCalculatorPipeline.{SynergyCalculator, SynergyGetter, SynergySave}
  alias TftHelper.Models.{Comp, Synergy}
  alias TftHelper.{Factorial, Logger, Repo}

  @synergy_processes Kernel.trunc(Application.get_env(:tft_helper, TftHelper.Repo)[:pool_size] / 2)
  @comp_processes Kernel.trunc(Application.get_env(:tft_helper, TftHelper.Repo)[:pool_size] / 2 / 3)

  @champions %{
    "Ahri" => ["Star Guardian", "Sorcerer"],
    "Annie" => ["Mech-Pilot", "Sorcerer"],
    "Ashe" => ["Celestial", "Sniper"],
    "Aurelion Sol" => ["Rebel", "Starship"],
    "Bard" => ["Astro", "Mystic"],
    "Blitzcrank" => ["Chrono", "Brawler"],
    "Caitlyn" => ["Chrono", "Sniper"],
    "Cassiopeia" => ["Battlecast", "Mystic"],
    "Darius" => ["Space Pirate", "Mana-Reaver"],
    "Ekko" => ["Cybernetic", "Infiltrator"],
    "Ezreal" => ["Chrono", "Blaster"],
    "Fiora" => ["Cybernetic", "Blademaster"],
    "Fizz" => ["Mech-Pilot", "Infiltrator"],
    "Gangplank" => ["Space Pirate", "Mercenary", "Demolitionist"],
    "Gnar" => ["Astro", "Brawler"],
    "Graves" => ["Space Pirate", "Blaster"],
    "Illaoi" => ["Battlecast", "Brawler"],
    "Irelia" => ["Cybernetic", "Mana-Reaver", "Blademaster"],
    "Janna" => ["Star Guardian", "Paragon"],
    "Jarvan IV" => ["Dark Star", "Protector"],
    "Jayce" => ["Space Pirate", "Vanguard"],
    "Jhin" => ["Dark Star", "Sniper"],
    "Jinx" => ["Rebel", "Blaster"],
    "Karma" => ["Dark Star", "Mystic"],
    "Kog'Maw" => ["Battlecast", "Blaster"],
    "Leona" => ["Cybernetic", "Vanguard"],
    "Lucian" => ["Cybernetic", "Blaster"],
    "Lulu" => ["Celestial", "Mystic"],
    "Malphite" => ["Rebel", "Brawler"],
    "Master Yi" => ["Rebel", "Blademaster"],
    "Mordekaiser" => ["Dark Star", "Vanguard"],
    "Nautilus" => ["Astro", "Vanguard"],
    "Neeko" => ["Star Guardian", "Protector"],
    "Nocturne" => ["Battlecast", "Infiltrator"],
    "Poppy" => ["Star Guardian", "Vanguard"],
    "Rakan" => ["Celestial", "Protector"],
    "Riven" => ["Chrono", "Blademaster"],
    "Rumble" => ["Mech-Pilot", "Demolitionist"],
    "Shaco" => ["Dark Star", "Infiltrator"],
    "Shen" => ["Chrono", "Blademaster"],
    "Soraka" => ["Star Guardian", "Mystic"],
    "Syndra" => ["Star Guardian", "Sorcerer"],
    "Teemo" => ["Astro", "Sniper"],
    "Thresh" => ["Chrono", "Mana-Reaver"],
    "Twisted Fate" => ["Chrono", "Sorcerer"],
    "Urgot" => ["Battlecast", "Protector"],
    "Vayne" => ["Cybernetic", "Sniper"],
    "Vi" => ["Cybernetic", "Brawler"],
    "Viktor" => ["Battlecast", "Sorcerer"],
    "Wukong" => ["Chrono", "Vanguard"],
    "Xayah" => ["Celestial", "Blademaster"],
    "Xerath" => ["Dark Star", "Sorcerer"],
    "Xin Zhao" => ["Celestial", "Protector"],
    "Yasuo" => ["Rebel", "Blademaster"],
    "Zed" => ["Rebel", "Infiltrator"],
    "Ziggs" => ["Rebel", "Demolitionist"],
    "Zoe" => ["Star Guardian", "Sorcerer"]
  }

  @champions_list @champions |> Map.keys |> Enum.sort

  @champions_size map_size(@champions)

  @synergies %{
    "Astro" => [3],
    "Battlecast" => [2, 4, 6, 8],
    "Blademaster" => [3, 6, 9],
    "Blaster" => [2, 4],
    "Brawler" => [2, 4],
    "Celestial" => [2, 4, 6],
    "Chrono" => [2, 4, 6, 8],
    "Cybernetic" => [3, 6],
    "Dark Star" => [2, 4, 6, 8],
    "Demolitionist" => [2],
    "Infiltrator" => [2, 4, 6],
    "Mana-Reaver" => [2],
    "Mech-Pilot" => [3],
    "Mercenary" => [1],
    "Mystic" => [2, 4],
    "Paragon" => [1],
    "Protector" => [2, 4, 6],
    "Rebel" => [3, 6, 9],
    "Sniper" => [2, 4],
    "Sorcerer" => [2, 4, 6],
    "Space Pirate" => [2, 4],
    "Star Guardian" => [3, 6, 9],
    "Starship" => [1],
    "Vanguard" => [2, 4, 6],
  }


  def create_comp(comp) do
    comp_str =
      comp
      |> Enum.map( fn c ->
        c
        |> Integer.to_string
        |> String.pad_leading(2, "0")
      end)
      |> Enum.join("")

    with {:error, changeset} <-
           %Comp{}
           |> Comp.changeset(%{comp: comp_str, size: length(comp)})
           |> Repo.insert() do
      Logger.error_log(changeset)
    end
  end

  def update_comp(%Comp{} = comp, synergy) do
    with {:error, changeset} <-
           comp
           |> Repo.preload(:synergy)
           |> Comp.changeset(%{})
           |> Ecto.Changeset.put_assoc(:synergy, synergy)
           |> Repo.update do
      Logger.error_log(changeset)
    end
  end

  def create_synergy(attrs) do
    attrs =
      attrs
      |> Enum.map(fn {key, value} ->
        {Recase.to_snake(key), value}
      end)
      |> Enum.into(%{})

    with {:error, changeset} <-
           %Synergy{}
           |> Synergy.changeset(attrs)
           |> Repo.insert() do
      Logger.error_log(changeset)
    end
  end

  def comp_str_to_list(nil) do
    nil
  end

  def comp_str_to_list(comp_str) do
    comp_str
    |> String.split(~r{\d\d}, include_captures: true, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def get_comp_names(%Comp{} = comp) do
    comp.comp
    |> comp_str_to_list
    |> Enum.map(&champion_name/1)
  end

  def calc_synergy(%Comp{} = comp) do
    comp
    |> get_comp_names
    |> Enum.reduce(%{}, fn champ, final_synergy ->
      Map.get(@champions, champ)
      |> Enum.reduce(final_synergy, fn syn, partial_synergy ->
        Map.put(partial_synergy, syn, Map.get(partial_synergy, syn, 0) + 1)
      end)
    end)
    |> calc_synergy_score_and_type
  end

  def calc_synergy_score_and_type(synergy) do
    score_type =
      synergy
      |> Enum.reduce(%{"score" => 0, "type" => [], "closed" => true},
           fn {champ_synergy , qt},%{"score" => score, "type" => type, "closed" => closed} ->
             syn_values = Map.get(@synergies, champ_synergy)
             if Enum.member?(syn_values, qt) do
               %{"score" => score + qt, "type" => type ++ [qt], "closed" => closed}
             else
               %{"score" => score, "type" => type, "closed" => false}
             end
           end)

    score_type =
      if score_type["closed"] do
        Map.merge(score_type, %{type: "closed"})
      else
        Map.merge(score_type,
          %{
            "type" => score_type["type"]
                      |> Enum.sort
                      |> Enum.reverse
                      |> Enum.join("-")
          })
      end

    Map.merge(synergy, score_type)
  end

  def calc_synergy_type(synergy) do
    type = ""

    Map.put(synergy, "type", type)
  end

  def start_generation() do
    {
      CompGenerator.start(8),
      CompValidator.start(8),
      1..@comp_processes |> Enum.map(&CompSave.start(8, &1)),

      CompGenerator.start(9),
      CompValidator.start(9),
      1..@comp_processes |> Enum.map(&CompSave.start(9, &1)),

      CompGenerator.start(10),
      CompValidator.start(10),
      1..@comp_processes |> Enum.map(&CompSave.start(10, &1)),

      SynergyGetter.start(),
      SynergyCalculator.start(),
      1..@synergy_processes |> Enum.map(&SynergySave.start(&1)),
    }
  end

  def stop_generation() do
    synergy_processes =
      1..@synergy_processes
      |> Enum.map(fn i ->
        Task.async(fn ->
          Logger.info_log("Stopping process SynergySave#{i}")
          SynergySave.stop(i)
          Logger.info_log("SynergySave#{i} Stopped")
        end)
      end)

    comp_processes8 =
      1..@comp_processes
      |> Enum.map(fn i ->
        Task.async(fn ->
          Logger.info_log("Stopping process CompSave8_#{i}")
          CompSave.stop(8, i)
          Logger.info_log("CompSave8_#{i} Stopped")
        end)
      end)

    comp_processes9 =
      1..@comp_processes
      |> Enum.map(fn i ->
        Task.async(fn ->
          Logger.info_log("Stopping process CompSave9_#{i}")
          CompSave.stop(9, i)
          Logger.info_log("CompSave9_#{i} Stopped")
        end)
      end)

    comp_processes10 =
      1..@comp_processes
      |> Enum.map(fn i ->
        Task.async(fn ->
          Logger.info_log("Stopping process CompSave10_#{i}")
          CompSave.stop(10, i)
          Logger.info_log("CompSave10_#{i} Stopped")
        end)
      end)

    synergy_processes ++ comp_processes8 ++ comp_processes9 ++ comp_processes10
    |> Enum.each(&Task.await(&1, :infinity))

    Logger.info_log("Stopping process SynergyCalculator")
    SynergyCalculator.stop()
    Logger.info_log("Stopping process SynergyStop")
    SynergyGetter.stop()

    Logger.info_log("Stopping process CompValidator 8")
    CompValidator.stop(8)
    Logger.info_log("Stopping process CompGenerator 8")
    CompGenerator.stop(8)

    Logger.info_log("Stopping process CompValidator 9")
    CompValidator.stop(9)
    Logger.info_log("Stopping process CompGenerator 9")
    CompGenerator.stop(9)

    Logger.info_log("Stopping process CompValidator 10")
    CompValidator.stop(10)
    Logger.info_log("Stopping process CompGenerator 10")
    CompGenerator.stop(10)

    Logger.info_log("Processes stopped")
  end

  def get_next_comp(comp, index \\ 0) do
    if length(comp) == index do
      nil
    else
      new_comp =
        comp
        |> Enum.with_index
        |> Enum.map(fn {c, i} ->
          if i == index do
            c + 1
          else
            c
          end

        end)

      if Enum.at(new_comp, index) >= champions_size() do
        get_next_comp(List.replace_at(comp, index, 0), index + 1)
      else
        new_comp
      end
    end

  end

  def champions() do
    @champions
  end

  def champions_size() do
    @champions_size
  end

  def champions_list() do
    @champions_list
  end

  def champion_name(champion_index) do
    @champions_list
    |> Enum.at(champion_index)
  end

  def comp_hash(comp) do
    comp
    |> Enum.with_index
    |> Enum.reduce(0, fn {v, p}, acc ->
      acc + v * :math.pow(10, p)
    end)
    |> Kernel.trunc
  end

  def find_missing_comp(comp_list, index \\ 0) do
    comp1 = Enum.at(comp_list, index)
    comp2 = Enum.at(comp_list, index + 1)
    if comp2.id - comp1.id == 1 do
      find_missing_comp(comp_list, index + 1)
    else
      Enum.at(comp_list, index)
    end
  end

  def get_last_inserted_comp() do
    stream = Repo.stream(from c in Comp, order_by: c.id)
    {:ok, resp} = Repo.transaction(fn ->
      stream
      |> find_missing_comp
    end)
    resp
  end

  def total_comps(size) do
    round(Factorial.of(champions_size()) /
      (Factorial.of(champions_size() - size) * Factorial.of(size)))
  end
end
