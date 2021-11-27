defmodule CryptoApiWeb.CoinView do
  use CryptoApiWeb, :view
  alias CryptoApiWeb.CoinView

  def render("index.json", %{coins: coins}) do
    %{data: render_many(coins, CoinView, "coin.json")}
  end

  def render("show.json", %{coin: coin}) do
    %{data: render_one(coin, CoinView, "coin.json")}
  end

  def render("coin.json", %{coin: coin}) do
    %{
      id: coin.id,
      ticker: coin.ticker,
      name: coin.name,
      price: coin.price
    }
  end
end
