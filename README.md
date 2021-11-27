# Elixir API Cookbook

## Install HEX, Phoenix and create app

<!-- livebook:{"disable_formatting":true} -->

```elixir
# install hex
mix local.hex  
#install phoenix
mix archive.install hex phx_new

#create new app
mix phx.new crypto_api --database mysql
```

## config Database at dev.exs

<!-- livebook:{"disable_formatting":true} -->

```elixir
#config Database at dev.exs
config :crypto_api, CryptoApi.Repo,
  username: "root",
  password: "sua senha",
  database: "crypto_api_dev",
  hostname: "localhost",
  port: 9999,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

## config Database at test.exs

<!-- livebook:{"disable_formatting":true} -->

```elixir
config :crypto_api, CryptoApi.Repo,
  username: "root",
  password: "sua senha",
  database: "crypto_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  port: 9999,
  pool_size: 10
```

## Create Database and run server

<!-- livebook:{"disable_formatting":true} -->

```elixir
mix ecto.create
mix phx.server
```

## Create and seed Database

<!-- livebook:{"disable_formatting":true} -->

```elixir
mix phx.gen.json Catalog Coin coins ticker:string:unique name:string price:decimal
```

<!-- livebook:{"disable_formatting":true} -->

```elixir
# priv/repo/migrations/20211111180810_create_coins.exs
add :price, :decimal, precision: 20, scale: 10
```

<!-- livebook:{"disable_formatting":true} -->

```elixir
mix ecto.migrate
```

Change `priv/repo/seeds.exs`:

```elixir
alias CryptoApi.Repo
alias CryptoApi.Catalog.Coin

Repo.delete_all("coins")

Repo.insert!(%Coin{ticker: "BTC", name: "Bitcoin", price: 65432.12})
Repo.insert!(%Coin{ticker: "ETH", name: "Ethereum", price: 4765.30})
Repo.insert!(%Coin{ticker: "DOT", name: "Polkadot", price: 48.90})
Repo.insert!(%Coin{ticker: "ADA", name: "Cardano", price: 2.20})
```

<!-- livebook:{"disable_formatting":true} -->

```elixir
mix run priv/repo/seeds.exs
```

Change the `router.ex` file:

```elixir
scope "/", CryptoApiWeb do
  pipe_through(:api)

  resources("/coins", CoinController)
end
```

<!-- livebook:{"disable_formatting":true} -->

```elixir
mix test
```

<!-- livebook:{"disable_formatting":true} -->

```elixir
git push origin main
```

## To production!

[Create GCP Database](https://console.cloud.google.com/sql/instances/create;engine=MySQL?project=tests-322618])

<!-- livebook:{"disable_formatting":true} -->

```elixir
# run the database locally to run migrations
cloud_sql_proxy -instances=tests-322618:us-central1:crypto-api=tcp:3306

# run database create
SECRET_KEY_BASE=1234 MIX_ENV=prod DATABASE_URL=ecto://root@127.0.0.1:3306/crypto-api mix ecto.create
# run database migrate
SECRET_KEY_BASE=1234 MIX_ENV=prod DATABASE_URL=ecto://root@127.0.0.1:3306/crypto-api mix ecto.migrate
SECRET_KEY_BASE=1234 MIX_ENV=prod DATABASE_URL=ecto://root@127.0.0.1:3306/crypto-api mix run priv/repo/seeds.exs
```

## Deploy to the GCP Cloud Run

`Dockerfile`

<!-- livebook:{"disable_formatting":true} -->

```elixir
FROM bitwalker/alpine-elixir-phoenix:1.12.2

# Set mix env and ports
ENV MIX_ENV=prod
ENV PORT=4000

# Cache elixir deps

WORKDIR /app

COPY . .

RUN rm -rf _build && rm -rf .elixir_ls
RUN mix clean

RUN mix deps.get
RUN mix deps.compile

# Run frontend build, compile, and digest assets
# RUN cd assets/ && npm run deploy
# RUN mix do compile, phx.digest

CMD ["mix", "phx.server"]
```

<!-- livebook:{"disable_formatting":true} -->

```elixir
steps:
  # build the container image
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/github.com/danicuki/crypto_api', '.']
  # push the container image to Container Registry
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/github.com/danicuki/crypto_api']
  # Deploy container image to Cloud Run
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['beta', 'run', 'deploy', 'crypto-api', 
  '--image', 'gcr.io/$PROJECT_ID/github.com/danicuki/crypto_api', 
  '--region', 'us-central1', '--allow-unauthenticated', '--port=4000', 
  '--add-cloudsql-instances=tests-322618:us-central1:crypto-api', 
  '--update-secrets=DATABASE_URL=crypto_api:latest,SECRET_KEY_BASE=crypto_api:latest']
images:
- gcr.io/$PROJECT_ID/github.com/danicuki/crypto_api
```

add to `prod.exs`

<!-- livebook:{"disable_formatting":true} -->

```elixir
config :crypto_api, CryptoApi.Repo,
  database: "crypto-api",
  socket: "/cloudsql/tests-322618:us-central1:crypto-api"

```

### Create secrets on GCP

<!-- livebook:{"disable_formatting":true} -->

```elixir
echo ecto://root@34.133.36.129/crypto-api? > database_secret.txt
gcloud secrets create crypto_api --data-file database_secret.txt
```

[Allow Secrets to Cloud Run](https://cloud.google.com/run/docs/configuring/secrets#access-secret)

<!-- livebook:{"break_markdown":true} -->

### Setup Cloud Build

<!-- livebook:{"break_markdown":true} -->

Set up a Cloud Build trigger
Now you set up Cloud Build to build on every code change in your GitHub repository.

Go to the [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers?_ga=2.169956644.521761273.1636579011-1870391259.1619387656&_gac=1.53036762.1633381849.CjwKCAjwzOqKBhAWEiwArQGwaERzxCo4IsXZ_376IZTAPQddU0BoLlScJujw4DJ5NV2B07DRFBfEVBoC6jAQAvD_BwE) page in the Cloud Console.

Create a new trigger for your Phoenix app, following the on-screen prompts. On the Trigger settings page, set the Build configuration to Cloud Build configuration file; everything else can stay at the default values.

<!-- livebook:{"break_markdown":true} -->

### Deploy

<!-- livebook:{"disable_formatting":true} -->

```elixir
git push origin main
```

## Refining

### Change coin view

```elixir
defmodule CryptoApiWeb.CoinView do
  use CryptoApiWeb, :view
  alias CryptoApiWeb.CoinView

  def render("index.json", %{coins: coins}) do
    render_many(coins, CoinView, "coin.json")
  end

  def render("show.json", %{coin: coin}) do
    render_one(coin, CoinView, "coin.json")
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
```

### Change Catalog GET to use ticker

```elixir
# catalog.ex
def get_coin!(ticker), do: Repo.get_by!(Coin, ticker: ticker)
```

