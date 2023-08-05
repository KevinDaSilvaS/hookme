defmodule Integrations.Users do
  use Agent
  @me __MODULE__

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @me)
  end

  def get_user(key) do
    Agent.get(@me, &Map.get(&1, key))
  end

  def add_user(key, task) do
    Agent.update(@me, &Map.put(&1, key, task))
  end
end
