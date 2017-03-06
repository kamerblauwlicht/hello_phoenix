FROM elixir:1.4.2-slim

ENV PHOENIX_VERSION 1.2.1
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new-$PHOENIX_VERSION.ez

RUN apt-get update && \
    apt-get install -y nodejs

RUN mix local.hex --force && \
    mix local.rebar --force

# Set exposed ports
EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod

# cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD package.json package.json
RUN npm install

COPY . .

# Run frontend build, compile, and digest assets
RUN brunch build --production && \
    mix do compile, phoenix.digest

USER default

CMD ["mix", "phoenix.server"]
