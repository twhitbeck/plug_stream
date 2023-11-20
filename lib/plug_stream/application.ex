defmodule PlugStream.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: PlugStream.Plug, options: [port: 3000]}
      # Starts a worker by calling: PlugStream.Worker.start_link(arg)
      # {PlugStream.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PlugStream.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
