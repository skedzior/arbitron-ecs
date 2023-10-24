defmodule Arbitron.Core.Utils do
  require Logger

  @doc "Generates a random base64 string of specified length"
  def random_string(length) do
    :crypto.strong_rand_bytes(length)
      |> Base.url_encode64
      |> binary_part(0, length)
  end

  def last_module(module) do
    Module.split(module)
    |> Enum.at(-1)
  end

  def lookup(name) do
    case Registry.lookup(Registry.Workers, name) do
      [{pid, _}] -> pid
      _ -> Logger.warn("Unable to locate process assigned to #{inspect(name)}")
    end
  end

  def broadcast(topic, msg) do
    Phoenix.PubSub.broadcast(Arbitron.PubSub, topic, msg)
  end

  def block_log_index(block_number, log_index) do
    if is_integer(block_number) && is_integer(log_index) do
      String.to_float("#{block_number}.#{log_index}")
    end
  end

  def to_int(hash) when is_nil(hash), do: nil
  def to_int(hash) do
    if String.length(hash) <= 2 do
      nil
    else
      hash
      |> String.slice(2..-1)
      |> Integer.parse(16)
      |> elem(0)
    end
  end
end
