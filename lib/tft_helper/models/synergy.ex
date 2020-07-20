defmodule TftHelper.Models.Synergy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "synergies" do
    field :astro, :integer
    field :battlecast, :integer
    field :blademaster, :integer
    field :blaster, :integer
    field :brawler, :integer
    field :celestial, :integer
    field :chrono, :integer
    field :cybernetic, :integer
    field :dark_star, :integer
    field :demolitionist, :integer
    field :infiltrator, :integer
    field :mana_reaver, :integer
    field :mech_pilot, :integer
    field :mercenary, :integer
    field :mystic, :integer
    field :paragon, :integer
    field :protector, :integer
    field :rebel, :integer
    field :sniper, :integer
    field :sorcerer, :integer
    field :space_pirate, :integer
    field :star_guardian, :integer
    field :starship, :integer
    field :vanguard, :integer
    field :type, :string
    field :score, :integer

    timestamps()
  end

  @doc false
  def changeset(synergy, attrs) do
    synergy
    |> cast(attrs, [:astro, :battlecast, :blademaster, :blaster, :brawler, :celestial, :chrono, :cybernetic,
      :dark_star, :demolitionist, :infiltrator, :mana_reaver, :mech_pilot, :mercenary, :mystic, :paragon,
      :protector, :rebel, :sniper, :sorcerer, :space_pirate, :star_guardian, :starship, :vanguard, :type, :score])
    |> validate_required([:score])
  end
end
