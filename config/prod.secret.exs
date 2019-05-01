use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :omscore, OmscoreWeb.Endpoint,
  secret_key_base: "UuUfhhDxYJ0wg6Drz4FYvrC+P36lLkoan4f4cW0LAtnPcpD8FVf6DKpfMy3ek09e"

# Configure your database
# Configure your database
config :omscore, Omscore.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: Helper.read_secret_from_file("/run/secrets/db_user", "postgres"),
  password: Helper.read_secret_from_file("/run/secrets/db_password", "5ecr3t"),
  database: "omscore_dev",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool_size: 10
