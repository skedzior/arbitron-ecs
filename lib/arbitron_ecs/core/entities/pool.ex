defmodule Pool do
  use Entity
  alias Arbitron.Uniswap.V3

  @topics %{
    mint: "0x7a53080ba414158be7ec69b987b5fb7d07dee101fe85488f0853ae16239d0bde",
    burn: "0x0c396cd989a39f4459b5fa1aed6a9a8dcdbc45908acfd67e028cd568da98982c",
    swap: "0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67"
  }

  defmodule State do
    defstruct [
      :sqrtp_x96,
      :liquidity,
      :tick,
      :tick_state,
      :tick_map,
      :p0,
      :p1,
      block: 0,
      log_index: 0
    ]

    def process_swap(event) do
      IO.inspect(V3.sqrtp_x96_to_price(event.sqrtp_x96), label: "pool price from sqrtp")
      IO.inspect(V3.tick_to_price(event.tick), label: "pool price from tick")

      %__MODULE__{
        sqrtp_x96: event.sqrtp_x96,
        tick: event.tick,
        liquidity: event.liquidity,
        # p0: D.div(r0, r1),
        # p1: D.div(r1, r0)
        block: event.block_number,
        log_index: event.log.log_index
      }
    end
  end

  @primary_key {:id, :id, autogenerate: true}
  schema "pools" do
    field :address, :string
    field :name, :string
    field :symbol, :string
    field :dex_id, :integer
    field :chain_id, :integer
    field :tick_spacing, :integer
    field :fee, :integer
    field :token0, :string
    field :token1, :string
    field :block_deployed, :integer
  end

  def topics, do: @topics

  def init(chain_id, address) do
    # get current tickmap etc
    Cachex.put(:pools, {chain_id, address}, %State{})

    get_by(chain_id, address)
    |> Map.put(:topics, @topics)
    |> Map.put(:stream_name, "#{chain_id}-Pool-#{address}")
  end

  def get_by(chain_id, address) do
    Repo.get_by(Pool, chain_id: chain_id, address: address)
  end
end
