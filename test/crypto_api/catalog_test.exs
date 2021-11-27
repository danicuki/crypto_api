defmodule CryptoApi.CatalogTest do
  use CryptoApi.DataCase

  alias CryptoApi.Catalog

  describe "coins" do
    alias CryptoApi.Catalog.Coin

    import CryptoApi.CatalogFixtures

    @invalid_attrs %{name: nil, price: nil, ticker: nil}

    test "list_coins/0 returns all coins" do
      coin = coin_fixture()
      assert Catalog.list_coins() == [coin]
    end

    test "get_coin!/1 returns the coin with given id" do
      coin = coin_fixture()
      assert Catalog.get_coin!(coin.id) == coin
    end

    test "create_coin/1 with valid data creates a coin" do
      valid_attrs = %{name: "some name", price: "120.5", ticker: "some ticker"}

      assert {:ok, %Coin{} = coin} = Catalog.create_coin(valid_attrs)
      assert coin.name == "some name"
      assert coin.price == Decimal.new("120.5")
      assert coin.ticker == "some ticker"
    end

    test "create_coin/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_coin(@invalid_attrs)
    end

    test "update_coin/2 with valid data updates the coin" do
      coin = coin_fixture()
      update_attrs = %{name: "some updated name", price: "456.7", ticker: "some updated ticker"}

      assert {:ok, %Coin{} = coin} = Catalog.update_coin(coin, update_attrs)
      assert coin.name == "some updated name"
      assert coin.price == Decimal.new("456.7")
      assert coin.ticker == "some updated ticker"
    end

    test "update_coin/2 with invalid data returns error changeset" do
      coin = coin_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_coin(coin, @invalid_attrs)
      assert coin == Catalog.get_coin!(coin.id)
    end

    test "delete_coin/1 deletes the coin" do
      coin = coin_fixture()
      assert {:ok, %Coin{}} = Catalog.delete_coin(coin)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_coin!(coin.id) end
    end

    test "change_coin/1 returns a coin changeset" do
      coin = coin_fixture()
      assert %Ecto.Changeset{} = Catalog.change_coin(coin)
    end
  end
end
