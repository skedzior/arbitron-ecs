defmodule ECS.Entity.Agent do

  def start_link(definition \\ %{}, opts \\ []) do
    Agent.start_link((fn -> definition end), opts)
  end

  def get(pid) do
    Agent.get(pid, &(&1))
  end

  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  def set(pid, new_state) do
    Agent.update(pid, &Map.merge(&1, new_state))
  end

  def set(pid, key, value) do
    Agent.update(pid, &Map.put(&1, key, value))
  end

  def set_and_get(pid, key, value) do
    set(pid, key, value)
    get(pid)
  end
end
