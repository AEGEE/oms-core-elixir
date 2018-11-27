defmodule Omscore.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # In test env, use ets to facilitate some interface testing
    if Application.get_env(:omscore, :env) == :test do
      :ets.new(:saved_mail, [:duplicate_bag, :public, :named_table])
      :ets.new(:core_fake_responses, [:set, :public, :named_table])
    end

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Omscore.Repo, []),
      # Start the endpoint when the application starts
      supervisor(OmscoreWeb.Endpoint, []),
      # Start your own worker by calling: Omscore.Worker.start_link(arg1, arg2, arg3)
      # worker(Omscore.Worker, [arg1, arg2, arg3]),
      worker(Omscore.ExpireTokens, [])
    ]


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Omscore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OmscoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
