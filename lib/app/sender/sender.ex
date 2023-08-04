defmodule Hookme.Sender do
  require Logger
  use GenServer

  @config Application.compile_env(:hookme, Hookme.Sender)
  @schedule_interval Keyword.get(@config, :schedule_interval)
  @reschedule_interval Keyword.get(@config, :reschedule_interval)
  @max_retry Keyword.get(@config, :max_retry)
  @webhook_url Keyword.get(@config, :webhook_url)

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  def send_info(data) do
    task = Task.async(fn -> send_data_to_client(data) end)
    Hookme.Keeper.add_task(task)
  end

  @impl true
  def handle_info({:work, data}, state) do
    send_data_to_client(data)
    {:noreply, state}
  end

  defp send_data_to_client(%{
         repository: reponame,
         username: username,
         retry: current_retry
       }) do
    current_retry = current_retry + 1

    case current_retry do
      @max_retry ->
        Logger.error("Max retry achieved for task #{reponame}/#{username}")

      _ ->
        Logger.info("Retrying operation #{reponame}/#{username} - retry: #{current_retry}")

        send_info(%{
          repository: reponame,
          username: username
        })
    end
  end

  defp send_data_to_client(data) do
    :timer.sleep(@schedule_interval)
    IO.inspect(data)
    IO.inspect("data sent to webhook")
  end
end
