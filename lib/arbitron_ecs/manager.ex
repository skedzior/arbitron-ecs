defmodule Arbitron.Manager do
  use DynamicSupervisor

  alias Arbitron.Streamer.Worker
  require Logger

  @provider Application.get_env(:rpc_provider, :eth)
  @chains Application.get_env(:blockchain, :chains)
  @pairs Application.get_env(:watch_list, :pairs)
  @pools Application.get_env(:watch_list, :pools)

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def autostart do
    autostart_chains()
    autostart_pairs()
    autostart_pools()
    #autostart_mempools()
  end

  def autostart_chains do
    Enum.map(@chains, fn c ->
      Chain.build(c, @provider)
      |> start_stream()
    end)
  end

  def autostart_pairs do
    Enum.map(@pairs, fn p ->
      Pair.build(p, @provider)
      |> start_stream()
    end)
  end

  def autostart_pools do
    Enum.map(@pools, fn p ->
      Pool.build(p, @provider)
      |> start_stream()
    end)
  end

  def autostart_mempools do
    Enum.map(@provider, fn p ->
      Mempool.new(p)
      |> start_stream()
    end)
  end

  defp start_stream(%{state: entity}), do: start_stream(entity)

  defp start_stream(entity) do
    DynamicSupervisor.start_child(__MODULE__, {Worker, entity})
  end
end
