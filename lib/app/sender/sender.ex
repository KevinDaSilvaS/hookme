defmodule Hookme.Sender do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  def send_info(data) do
    task = Task.async(fn -> do_recurrent_thing(data) end)
    Hookme.Keeper.add_task(task)
  end

  @impl true
  def handle_info({:work, data}, state) do
    do_recurrent_thing(data)
    {:noreply, state}
  end

  defp do_recurrent_thing(data) do
    :timer.sleep(10800)
    IO.inspect(data)
    IO.inspect("data sent to webhook")
  end
end
