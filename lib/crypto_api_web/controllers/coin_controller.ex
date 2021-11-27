defmodule CryptoApiWeb.CoinController do
  use CryptoApiWeb, :controller

  alias CryptoApi.Catalog
  alias CryptoApi.Catalog.Coin

  action_fallback CryptoApiWeb.FallbackController

  def index(conn, _params) do
    coins = Catalog.list_coins()
    render(conn, "index.json", coins: coins)
  end

  def create(conn, %{"coin" => coin_params}) do
    with {:ok, %Coin{} = coin} <- Catalog.create_coin(coin_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.coin_path(conn, :show, coin))
      |> render("show.json", coin: coin)
    end
  end

  def show(conn, %{"id" => id}) do
    coin = Catalog.get_coin!(id)
    render(conn, "show.json", coin: coin)
  end

  def update(conn, %{"id" => id, "coin" => coin_params}) do
    coin = Catalog.get_coin!(id)

    with {:ok, %Coin{} = coin} <- Catalog.update_coin(coin, coin_params) do
      render(conn, "show.json", coin: coin)
    end
  end

  def delete(conn, %{"id" => id}) do
    coin = Catalog.get_coin!(id)

    with {:ok, %Coin{}} <- Catalog.delete_coin(coin) do
      send_resp(conn, :no_content, "")
    end
  end
end
