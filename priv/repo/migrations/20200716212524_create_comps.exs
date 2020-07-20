defmodule TftHelper.Repo.Migrations.CreateComps do
  use Ecto.Migration

  def change do
    create table(:comps) do
      add :comp, :string
      add :synergy_id, references(:synergies, on_delete: :nothing)
      add :size, :integer

      timestamps()
    end

    create index(:comps, [:synergy_id])

    create unique_index(:comps, [:comp])
  end
end
