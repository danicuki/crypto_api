defmodule CryptoApi.Repo.Migrations.CreateCoins do
  use Ecto.Migration

  def change do
    create table(:coins) do
      add :ticker, :string
      add :name, :string
      add :price, :decimal, precision: 20, scale: 10

      timestamps()
    end
  end
end
