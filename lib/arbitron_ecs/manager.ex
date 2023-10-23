defmodule Arbitron.Manager do
  use DynamicSupervisor

  alias Arbitron.Streamer

  @provider Application.get_env(:rpc_providers, :eth)
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
    ECS.Registry.start

    autostart_streamers()
  end

  def autostart_streamers do
    autostart_chains()
    autostart_pairs()
    autostart_pools()
    #autostart_mempools()
  end

  def autostart_chains do
    Enum.map(@chains, fn c ->
      Chain.new(c)
      |> start_stream()
    end)
  end

  def autostart_pairs do
    Enum.map(@pairs, fn p ->
      Pair.new(p)
      |> start_stream()
    end)
  end

  def autostart_pools do
    Enum.map(@pools, fn p ->
      Pool.new(p)
      |> start_stream()
    end)
  end

  def autostart_mempools do
    start_stream({Streamer.Mempool, @provider})
  end

  defp start_stream(entity) do
    DynamicSupervisor.start_child(__MODULE__, {Streamer.Worker, entity})
  end
end
