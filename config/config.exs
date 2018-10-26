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
  expiry_worker_freq: 5 * 60 * 1000   # 5 Minutes

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
  from: "oms@aegee.org",
  mail_service: :sendgrid

config :omscore, Omscore.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "mail.aegee.org",
  hostname: "aegee.org",
  port: 587,
  username: Helper.read_secret_from_file(System.get_env("MAIL_USER"), "oms"), # or {:system, "SMTP_USERNAME"}
  password: Helper.read_secret_from_file(System.get_env("MAIL_PASSWORD"), "oms"), # or {:system, "SMTP_PASSWORD"}
  tls: :if_available, # can be `:always` or `:never`
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"], # or {":system", ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  ssl: false, # can be `true`
  retries: 3,
  no_mx_lookups: false, # can be `true`
  auth: :always # can be `always`. If your smtp relay requires authentication set it to `always`.

#config :omscore, Omscore.Mailer,
#  adapter: Bamboo.SendgridAdapter,
#  api_key: String.trim(Helper.read_secret_from_file(System.get_env("SENDGRID_KEY_FILE"), "censored"))

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
