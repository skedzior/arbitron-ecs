defmodule EntityDefinition do
  use ECS.Component

  def new(%{__struct__: component_type} = definition) do
    ECS.Component.new(component_type, definition)
  end
end
