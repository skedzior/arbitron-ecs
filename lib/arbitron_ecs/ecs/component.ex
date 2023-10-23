defmodule ECS.Component do
  defstruct [:id, :state]

  @type id :: pid()
  @type component_type :: String.t
  @type state :: map()
  @type t :: %ECS.Component{
    id: id, # Component Agent ID
    state: state
  }

  @callback new(state) :: t # Component interface

  defmacro __using__(_options) do
    quote do
      @behaviour ECS.Component
    end
  end

  @spec new(state) :: t
  def new(%{name: name, __struct__: component_type} = initial_state) do
    {:ok, pid} = ECS.Component.Agent.start_link(initial_state, [name: :"#{component_type}-#{name}"])
    ECS.Registry.insert(component_type, pid) # Register component for systems to reference
    %{
      id: pid,
      state: initial_state
    }
  end

  @spec new(component_type, state) :: t
  def new(component_type, initial_state) do
    {:ok, pid} = ECS.Component.Agent.start_link(initial_state)
    ECS.Registry.insert(component_type, pid) # Register component for systems to reference
    %{
      id: pid,
      state: initial_state
    }
  end

  @spec get(id) :: t
  def get(pid) do
    state = ECS.Component.Agent.get(pid)

    %{
      id: pid,
      state: state
    }
  end

  @spec update(id, state) :: t
  def update(pid, new_state) do
    ECS.Component.Agent.set(pid, new_state)

    %{
      id: pid,
      state: new_state
    }
  end
end
