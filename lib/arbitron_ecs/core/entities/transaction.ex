defmodule Transaction do
  def new(tx) do
    ECS.Entity.build([PendingTx.new(tx)])
  end
end
