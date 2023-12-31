defmodule Hookme.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  HTTPoison.start

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Hookme.Worker.start_link(arg)
      # {Hookme.Worker, arg}
      Hookme.Keeper,
      {Hookme.Sender, ""},
      Integrations.Users,
      {Plug.Cowboy, scheme: :http, plug: Server.Router, options: [port: 4001]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hookme.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
