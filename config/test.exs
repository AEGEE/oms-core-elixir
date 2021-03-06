use Mix.Config

config :omscore,
  supertoken: "supertoken"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :omscore, OmscoreWeb.Endpoint,
  http: [port: 4001],
  server: false,
  max_login_attempts: 1000000

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
  password: "5ecr3t",
  database: "omscore_test",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
