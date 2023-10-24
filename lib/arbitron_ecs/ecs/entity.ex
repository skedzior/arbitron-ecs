defmodule ECS.Entity do
  import Arbitron.Core.Utils
  alias Arbitron.Streamer.Stream

  defstruct [:id, :entity_type, :state, :name]

  @type id :: String.t
  @type entity_type :: atom()
  @type state :: map()
  @type provider :: map()
  @type name :: String.t
  @type t :: %ECS.Entity{
    id: id,
    entity_type: entity_type,
    state: state,
    name: name
  }

  @callback build(state, provider) :: t

  defmacro __using__(_options) do
    quote do
      use TypedStruct
      @behaviour ECS.Entity # Require Components to implement interface
    end
  end

  @spec build(state, provider) :: t
  def build(%{__struct__: entity_type} = state, provider) do
    name = Stream.name(state, provider)

    {:ok, pid} = ECS.Entity.Agent.start_link(state, name: via_tuple(name))

    %{
      id: pid,
      entity_type: entity_type,
      state: state,
      name: name
    }
  end

  def update(pid, key, value) when is_pid(pid) do
    ECS.Entity.Agent.set(pid, key, value)
  end

  def update(%{id: pid} = entity, key, value) do
    ECS.Entity.Agent.set(pid, key, value)
  end

  def update_and_get(%{id: pid} = entity, key, value) do
    ECS.Entity.Agent.set_and_get(pid, key, value)
  end

  defp via_tuple(name) do
    {:via, Registry, {Registry.Workers, name}}
  end
end
