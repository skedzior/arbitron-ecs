defmodule Entity do
  defmacro __using__(_options) do
    quote do
      use Ecto.Schema

      import Ecto.Query, warn: false
      alias Arbitron.Repo

      alias Decimal, as: D
      D.Context.set(%D.Context{D.Context.get() | precision: 80})

      @behaviour Entity # Require Components to implement interface

      def name(chain_id, entity, %{name: name}) do
        module = Module.split(__MODULE__) |> Enum.at(-1)

         "#{chain_id}-#{module}-#{entity.symbol}-#{name}"
      end

      def name(%{} = chain, provider) do
        module = Module.split(__MODULE__) |> Enum.at(-1)

        "#{chain.name}-#{module}-#{provider.name}"
      end
    end
  end
end
