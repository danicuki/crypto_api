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
