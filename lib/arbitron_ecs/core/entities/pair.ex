defmodule Pair do
  use Entity

  @topics %{
    sync: "0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1"
  }

  defmodule State do
    defstruct [:r0, :r1, :p0, :p1, block: 0, log_index: 0]

    def process_sync(%{reserve0: r0, reserve1: r1, block_number: block, log_index: log}) do
      {r0, r1} = {D.new(r0), D.new(r1)}

      %__MODULE__{
        r0: r0,
        r1: r1,
        p0: D.div(r0, r1),
        p1: D.div(r1, r0),
        block: block,
        log_index: log
      }
    end
  end

  @primary_key {:id, :id, autogenerate: true}
  schema "pairs" do
    field :address, :string
    field :name, :string
    field :symbol, :string
    field :dex_id, :integer
    field :chain_id, :integer
    field :fee, :integer # default: 30
    field :token0, :string # token()
    field :token1, :string
    #field :block_deployed, :integer
  end

  def init(chain_id, address) do
    #[r0, r1] = Forge.get_reserves_at_block(address)
    Cachex.put(:pairs, {chain_id, address}, %State{})

    get_by(chain_id, address)
    |> Map.put(:topics, @topics)
    |> Map.put(:stream_name, "#{chain_id}-Pair-#{address}")
  end

  def topics, do: @topics

  def get_by(chain_id, address) do
    Repo.get_by(Pair, chain_id: chain_id, address: address)
  end
end
