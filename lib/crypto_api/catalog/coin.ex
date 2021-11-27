defmodule CryptoApi.Catalog.Coin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "coins" do
    field :name, :string
    field :price, :decimal
    field :ticker, :string

    timestamps()
  end

  @doc false
  def changeset(coin, attrs) do
    coin
    |> cast(attrs, [:ticker, :name, :price])
    |> validate_required([:ticker, :name, :price])
  end
end
