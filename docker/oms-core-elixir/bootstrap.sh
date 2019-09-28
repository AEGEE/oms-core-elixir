#/bin/ash

npm install
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
