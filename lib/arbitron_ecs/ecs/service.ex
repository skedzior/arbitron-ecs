defmodule ECS.Service do

  @callback process(String.t, tuple()) :: :void
  @callback dispatch(pid(), tuple()) :: :void

  defmacro __using__(_options) do
    quote do
      import Arbitron.Core.Utils
      alias Arbitron.Core.EventDecoder
      require Logger

      @behaviour ECS.Service
    end
  end
end
