defmodule ECS.Entity do
  import Arbitron.Core.Utils

  defstruct [:id, :entity_type, :components]

  @type id :: String.t
  @type entity_type :: atom()
  @type components :: list(ECS.Component)
  @type t :: %ECS.Entity{
    id: String.t,
    entity_type: entity_type,
    components: components
  }

  @spec build(ECS.Component.t) :: t
  def build(definition_component) do
    %ECS.Entity{
      id: random_string(64),
      entity_type: definition_component.state.__struct__,
      components: [definition_component]
    }
  end

  @spec build(ECS.Component.t, components) :: t
  def build(definition_component, components) do
    %ECS.Entity{
      id: random_string(64),
      entity_type: definition_component.state.__struct__,
      components: Enum.concat([definition_component], components)
    }
  end

  @spec add(t, ECS.Component.t) :: t
  def add(%ECS.Entity{id: id, entity_type: entity_type, components: components}, component) do
    %ECS.Entity{
      id: id,
      entity_type: entity_type,
      components: components ++ [component]
    }
  end

  @spec reload(t) :: t
  def reload(%ECS.Entity{ id: _id, components: components} = entity) do
    updated_components =
      Enum.map(components, fn %{id: pid} ->
        ECS.Component.get(pid)
      end)

    %{entity | components: updated_components}
  end
end
