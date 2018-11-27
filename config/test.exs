use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :omscore, OmscoreWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# For testing we don't need secure tokens, so speed up tests by reducing rounds
config :bcrypt_elixir, :log_rounds, 4

# Use a mock adapter for testing
config :tesla, adapter: Tesla.Mock


# Configure your database
config :omscore, Omscore.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "omscore_test",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
