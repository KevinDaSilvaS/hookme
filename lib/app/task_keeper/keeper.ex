defmodule Hookme.Keeper do
  use Agent
  @me __MODULE__

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @me)
  end

  def get_tasks do
    Agent.get(@me, & &1)
  end

  def get_one_task(key) do
    Agent.get(@me, &Map.get(&1, key))
  end

  def add_task(key, task) do
    Agent.update(@me, &Map.put(&1, key, task))
  end

  def remove_task(key) do
    Agent.update(@me, &Map.delete(&1, key))
  end
end
