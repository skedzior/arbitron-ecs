defmodule Core.Contracts.V3FactoryContract do
  alias Core.Infura

  use GenServer

  @factories [
    {:UniswapV3Factory, "0x1F98431c8aD98523631AE4a59f267346ea31F984", :V3_FACTORY}
  ]

  # https://etherscan.io/address/0x1f98431c8ad98523631ae4a59f267346ea31f984
  # can i scrape from this endpoint? ^

  defmodule State do
    defstruct [
      :registered
    ]
  end

  defp base_path, do: "abis/"

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :v3_factory_server)
  end

  @impl true
  def init(state) do
    {:ok, %State{
      registered: []
    }}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  def register(contract_address, name, type) do
    factory = String.to_atom(name <> "_" <> contract_address)
    contract_abi = Web3x.Abi.load_abi(base_path() <> Atom.to_string(type) <> ".json")

    IO.inspect(factory)

    Web3x.Contract.register(factory, abi: contract_abi)
    Web3x.Contract.at(factory, contract_address)

    GenServer.cast(:v3_factory_server, {:register, factory})
  end

  def get_state do
    :sys.get_state(:v3_factory_server)
  end

  @impl true
  def handle_cast({:register, contract}, state) do
    registered = state.registered
    new_state = %{state | registered: [contract | registered]}
    IO.inspect(new_state)
    {:noreply, new_state}
  end

  # ------------------------------------- #
  #        Contract Event Functions       #
  # ------------------------------------- #

  def remove_filters_for(filter_ids_list) do
    for filter <- filter_ids_list do
      Web3x.Contract.uninstall_filter(filter)
    end
  end

  def event_filter(factory \\ :UniswapV2Pair) do
    {:ok, filter_id} =
      Web3x.Contract.filter(
        factory,
        "Mint",
        base_filter_data()
      )

      filter_id
  end

  def get_pair_length(factory \\ :UniswapV2Factory) do
    {:ok, pair_length} = Web3x.Contract.call(factory, :allPairsLength)

    pair_length
  end

  def get_pair(token0, token1, factory \\ :UniswapV2Factory) do
    {:ok, bytes} = Web3x.Contract.call(factory, :getPair, [token0, token1])

    Web3x.Utils.to_address(bytes)
  end

  def get_pair_by_index(index, factory \\ :UniswapV2Factory) do
    {:ok, bytes} = Web3x.Contract.call(factory, :allPairs, [index])
    IO.inspect(bytes)
    Web3x.Utils.to_address(bytes)
  end

  # Every filter we create will need to specify fromBlock and toBlock
  def base_filter_data, do: %{fromBlock: Infura.get_current_block_number() - 25, toBlock: "latest"}
end
