defmodule TftHelper.Repo.Migrations.CreateSynergies do
  use Ecto.Migration

  def change do
    create table(:synergies) do
      add :astro, :integer
      add :battlecast, :integer
      add :blademaster, :integer
      add :blaster, :integer
      add :brawler, :integer
      add :celestial, :integer
      add :chrono, :integer
      add :cybernetic, :integer
      add :dark_star, :integer
      add :demolitionist, :integer
      add :infiltrator, :integer
      add :mana_reaver, :integer
      add :mech_pilot, :integer
      add :mercenary, :integer
      add :mystic, :integer
      add :paragon, :integer
      add :protector, :integer
      add :rebel, :integer
      add :sniper, :integer
      add :sorcerer, :integer
      add :space_pirate, :integer
      add :star_guardian, :integer
      add :starship, :integer
      add :vanguard, :integer

      add :type, :string
      add :score, :integer

      timestamps()
    end

    create unique_index(:synergies, [
      :astro,
      :battlecast,
      :blademaster,
      :blaster,
      :brawler,
      :celestial,
      :chrono,
      :cybernetic,
      :dark_star,
      :demolitionist,
      :infiltrator,
      :mana_reaver,
      :mech_pilot,
      :mercenary,
      :mystic,
      :paragon,
      :protector,
      :rebel,
      :sniper,
      :sorcerer,
      :space_pirate,
      :star_guardian,
      :starship,
      :vanguard,
    ], name: :synergy_synergies_index)
  end
end
