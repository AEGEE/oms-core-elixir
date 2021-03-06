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
      {:ok, content} -> String.trim(content)
      {:error, _} -> fallback
    end
  end
end

# General application configuration
config :omscore,
  ecto_repos: [Omscore.Repo],
  env: Mix.env,
  url_prefix: System.get_env("BASE_URL") || "my.aegee.eu",
  ttl_refresh: 60 * 60 * 24 * 7 * 2,  # 2 weeks
  ttl_access: 60 * 60,                # 1 hour
  ttl_password_reset: 60 * 15,        # 15 Minutes
  ttl_mail_confirmation: 60 * 60 * 2, # 2 hours
  max_login_attempts: 100,            # Max number of login attempts
  login_attempt_decay: 300,           # 5 Minutes, time after which a login attempt is forgotten
  expiry_worker_freq: 5 * 60 * 1000,  # 5 Minutes
  mail_confirmation_resends: 50,      # How often a user can request resend of his confirmation mail within the expiration interval
  supertoken: Helper.read_secret_from_file(System.get_env("SUPERTOKEN_FILE"), nil) # The supertoken grants full access to everything

# Configures the endpoint
config :omscore, OmscoreWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yHNfTDYdKE4X2gelgWU5vNE7WV0+Mdcgau0JXz+w0xVLrkFOtyssa1fAR5OGY2Nj",
  render_errors: [view: OmscoreWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Omscore.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :omscore, Omscore.Guardian,
  issuer: System.get_env("JWT_ISSUER") || "OMS", 
  secret_key: String.trim(Helper.read_secret_from_file(System.get_env("JWT_SECRET_KEY_FILE"), "rrSTfyfvFlFj1JCl8QW/ritOLKzIncRPC5ic0l0ENVUoiSIPBCDrdU6Su5vZHngY"))

config :omscore, Omscore.Interfaces.Mail,
  oms_mailer_dns: "http://oms-mailer:4000"

# Configures the http library
config :tesla, adapter: Tesla.Adapter.Hackney


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
