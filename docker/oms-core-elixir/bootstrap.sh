#/bin/ash

mix deps.get

cd ./assets/
npm install
cd ../

mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
