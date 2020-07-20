defmodule TftHelper.Models.Comp do
  use Ecto.Schema
  import Ecto.Changeset

  alias TftHelper.Models.Synergy

  schema "comps" do
    field :comp, :string
    field :size, :integer

    belongs_to :synergy, Synergy

    timestamps()
  end

  @doc false
  def changeset(comp, attrs) do
    comp
    |> cast(attrs, [:comp, :size])
    |> validate_required([:comp, :size])
    |> unique_constraint(:comp)
  end
end
