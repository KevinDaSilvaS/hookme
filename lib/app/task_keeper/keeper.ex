defmodule Hookme.Keeper do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get_tasks do
    Agent.get(__MODULE__, & &1)
  end

  def add_task(task) do
    Agent.update(__MODULE__, &([task | &1]))
  end
end
