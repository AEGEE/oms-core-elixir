# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

defmodule Helper do
  def read_secret_from_file(nil, fallback), do: fallback
  def read_secret_from_file(file, fallback) do
    case File.read(file) do
      {:ok, content} -> content
      {:error, _} -> fallback
    end
  end
end

# General application configuration
config :omscore,
  ecto_repos: [Omscore.Repo]

# Configures the endpoint
config :omscore, OmscoreWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yHNfTDYdKE4X2gelgWU5vNE7WV0+Mdcgau0JXz+w0xVLrkFOtyssa1fAR5OGY2Nj",
  render_errors: [view: OmscoreWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Omscore.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :omscore, Omscore.Guardian,
  issuer: System.get_env("JWT_ISSUER") || "OMS", 
  secret_key: Helper.read_secret_from_file(System.get_env("JWT_SECRET_KEY_FILE"), "rrSTfyfvFlFj1JCl8QW/ritOLKzIncRPC5ic0l0ENVUoiSIPBCDrdU6Su5vZHngY")


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
