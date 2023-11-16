defmodule Dex do
  use Entity

  @topics %{
    pair_created: "0x0d3648bd0f6ba80134a33ba9275ac585d9d315f0ad8355cddefde31afa28d0e9",
    pool_created: "0x783cca1c0412dd0d695e784568c96da2e9c22ff989357a2e8b1d9b2b4e6b7118"
  }
  # TODO: make sure we check dex type to get proper topics - above are for v2 only?

  @primary_key {:id, :id, autogenerate: true}
  schema "dexes" do
    field :name, :string
    field :chain_id, :integer
    field :fee, :integer
    field :type, Ecto.Enum, values: [:v2, :v3, :bal]
    field :block_deployed, :integer
    field :factory_address, :string
    field :gql_url, :string
  end

  def init(chain_id, id) do
    #Cachex.put(:dexes, id, %State{})

    dex = get!(id)

    topics =
      case dex.type do
        :v2 -> %{pair_created: @topics.pair_created}
        :v3 -> %{pool_created: @topics.pool_created}
        _ -> nil #IO.inspect("not supported dex type")
      end

    Map.put(dex, :topics, topics)
    |> Map.put(:stream_name, "#{chain_id}-Dex-#{dex.name}-#{Atom.to_string(dex.type)}")
  end

  def topics, do: @topics

  def all, do: Repo.all(Dex)

  def get!(dex_id), do: Repo.get!(Dex, dex_id)

  def get_by(chain_id, type) do
    from(d in Dex, where: d.type == ^type and d.chain_id == ^chain_id)
    |> Repo.all
  end
end

 # name: "UniswapV2",
 # router_address: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
 # factory_address: "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
 # lps: [
 #   %{
 #     address: "0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc",
 #     symbol: "USDC-WETH"
 #   },
 #   %{
 #     address: "0x0d4a11d5eeaac28ec3f61d100daf4d40471f1852",
 #     symbol: "WETH-USDT"
 #   },
 #   %{
 #     address: "0xae461ca67b15dc8dc81ce7615e0320da1a9ab8d5",
 #     symbol: "DAI-USDC"
 #   }
 # ]
