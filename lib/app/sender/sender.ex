defmodule Hookme.Sender do
  require Logger
  use GenServer

  alias Integrations.GithubApiIntegration

  @config Application.compile_env(:hookme, Hookme.Sender)
  @schedule_interval Keyword.get(@config, :schedule_interval)
  @reschedule_interval Keyword.get(@config, :reschedule_interval)
  @max_retry Keyword.get(@config, :max_retry)

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  def send_info(data) do
    key = Map.fetch!(data, :username) <> "/" <> Map.fetch!(data, :repository)
    task_for_key_exists = Hookme.Keeper.get_one_task(key)

    if is_nil(task_for_key_exists) do
      task = Task.async(fn -> send_data_to_client(data) end)
      Hookme.Keeper.add_task(key, task)
    end
  end

  defp set_interval(retry_stage) do
    case retry_stage do
      0 -> wait_for(@schedule_interval)
      _ -> wait_for(@reschedule_interval)
    end
  end

  defp wait_for(interval) do
    :timer.sleep(interval)
  end

  defp retry_job(current_retry, username, repository) do
    if current_retry < @max_retry do
      Logger.error(
        "failed to send task #{username}/#{repository} to client. Retrying attempt #{current_retry}"
      )

      send_info(%{
        username: username,
        repository: repository,
        retry: current_retry
      })
    else
      Logger.error("Max retry achieved for task #{username}/#{repository}")
    end
  end

  defp send_data_to_client(data) do
    current_retry = Map.get(data, :retry, -1) + 1
    set_interval(current_retry)

    username = Map.fetch!(data, :username)
    repository = Map.fetch!(data, :repository)

    key = username <> "/" <> repository
    Hookme.Keeper.remove_task(key)

    {result, data} = GithubApiIntegration.fetch_repo_data(username, repository)

    case result do
      :ok -> IO.inspect(data)
      _ -> retry_job(current_retry, username, repository)
    end
  end
end
