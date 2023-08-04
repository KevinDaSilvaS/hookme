defmodule Hookme.Entrypoint do
  require Logger
  alias App.Validators.EntrypointValidators
  use GenServer
  @me __MODULE__

  def start_link(_) do
    GenServer.start_link @me, :no_args, name: @me
  end

  def call_cli() do
    username = IO.gets("Please enter the GitHub username?\n")
               |> String.Chars.to_string()
               |> EntrypointValidators.sanitize_input()

    reponame = IO.gets("Please enter the GitHub repo?\n")
               |> String.Chars.to_string()
               |> EntrypointValidators.sanitize_input()

    proceed = IO.gets("Proceed?[Y/n]\n")
              |> String.Chars.to_string()
              |> EntrypointValidators.sanitize_input()
              |> EntrypointValidators.validate_proceed()

    if proceed do
      Hookme.Sender.send_info(%{username: username, repository: reponame})
      Logger.info("Task to fetch data for #{username}'s #{reponame}")
    end
    call_cli()
  end

  def init(:no_args) do
    call_cli()
    { :ok, %{} }
  end

end
