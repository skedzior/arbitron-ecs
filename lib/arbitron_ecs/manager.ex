defmodule Arbitron.Manager do
  use DynamicSupervisor

  alias Arbitron.Streamer.{Counter, Worker}
  require Logger

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def autostart do
    Counter.setup()

    Cachex.start(:chains)
    Cachex.start(:pairs)
    Cachex.start(:pools)

    [
      %{
        chain_id: 1,
        #provider: 1,
        dexes: [1, 2, 3, 4, 5, 6],
        pools: [
          "0x6ce6d6d40a4c4088309293b0582372a2e6bb632e",
          "0x7524fe020edcd072ee98126b49fa65eb85f8c44c",
          "0x8592064903ef23d34e4d5aaaed40abf6d96af186",
          "0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8",
          "0x1ac1a8feaaea1900c4166deeed0c11cc10669d36",
          "0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640"
        ],
        pairs: [
          "0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc", #usdc_weth uni
          "0x397ff1542f962076d0bfe58ea045ffa2d347aca0" #usdc_weth sushi
        ],
        tokens: [
          "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
          "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
          "0xaf5191b0de278c7286d6c7cc6ab6bb8a73ba2cd6"
        ],
        mempool: false
      },
      %{
        chain_id: 10,
        dexes: [],
        pools: [],
        pairs: [],
        tokens: [],
        mempool: false
      },
      %{
        chain_id: 137,
        dexes: [],
        pools: [],
        pairs: [],
        tokens: [],
        mempool: false
      },
      %{
        chain_id: 250,
        dexes: [],
        pools: [],
        pairs: [],
        tokens: [],
        mempool: false
      },
      %{
        chain_id: 42161,
        dexes: [],
        pools: [],
        pairs: [],
        tokens: [],
        mempool: false
      },
      %{
        chain_id: 8453,
        dexes: [],
        pools: [],
        pairs: [],
        tokens: [],
        mempool: false
      }
    ]
    |> Enum.map(fn c ->
      chain = Chain.get!(c.chain_id)
      provider = Provider.get_by(c.chain_id)

      chain
      |> Map.put(:topics, Chain.topics)
      |> Map.put(:stream_name, Chain.name(chain, provider))
      |> start_stream(provider)

      #start_dexes(chain, provider, c.dexes)
      start_pairs(chain, provider, c.pairs)
      #start_pools(chain, provider, c.pools)

      if c.mempool do
        chain
        |> Map.put(:topics, Mempool.topics)
        |> start_stream(provider)
      end
    end)

    #Arbitron.Streamer.Kucoin.start_link()
  end

  def start_chains do
    Cachex.start(:chains)

    Chain.get_with_provider
    |> Enum.map(&start_stream(&1, &2))
  end

  def start_dexes(%Chain{chain_id: chain_id}, provider, ids) do
    Enum.map(ids, fn id ->
      Dex.init(chain_id, id)
      #|> start_stream(provider)
    end)
  end

  def start_pairs(%Chain{chain_id: chain_id}, provider, addresses) do
    Enum.map(addresses, fn adr ->
      Pair.init(chain_id, adr)

      Pair.get_by(chain_id, adr)
      |> Map.put(:topics, Pair.topics)
      |> Map.put(:stream_name, "#{chain_id}-Pair-#{adr}")
      |> start_stream(provider)
    end)
  end

  def start_pools(%Chain{chain_id: chain_id}, provider, addresses) do
    Enum.map(addresses, fn adr ->
      Pool.init(chain_id, adr)

      Pool.get_by(chain_id, adr)
      |> Map.put(:topics, Pool.topics)
      |> Map.put(:stream_name, "#{chain_id}-Pool-#{adr}")
      |> start_stream(provider)
    end)
  end

  defp start_stream(entity, provider) do
    DynamicSupervisor.start_child(__MODULE__, {Worker, {entity, provider}})
  end
end
