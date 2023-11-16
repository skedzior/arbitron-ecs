defmodule ArbitronWeb.ChainsLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  def render(assigns) do
    ~L"""
      <div class="flex items-center">
        <div class="stats stats-vertical lg:stats-horizontal shadow mx-auto">

          <%= for chain <- @chains do %>
            <div class="stat">
              <div class="stat-title"><%= chain.name %></div>
              <div class="stat-value"><%= Map.get(@block_list, chain.chain_id) %></div>
              <div class="stat-desc"></div>
            </div>
          <% end %>

        </div>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    chains = list_chains()
    #Phoenix.PubSub.subscribe(Arbitron.PubSub, "chain_event")
    IO.inspect(chains, label: "chains")

    block_list =
      Enum.reduce(chains, %{}, fn c, acc ->
        Phoenix.PubSub.subscribe(Arbitron.PubSub, "CHAIN_EVENT:#{c.chain_id}")
        Map.put(acc, c.chain_id, 0)
      end)

    {:ok, assign(socket, chains: chains, block_list: block_list)}
  end

  # def toggle_selected(js \\ %JS{}) do
  #   js
  #   |> JS.remove_class(
  #     "selected",
  #     to: "#event_table.selected"
  #   )
  #   |> JS.add_class(
  #     "selected",
  #     to: "#event_table:not(.selected)"
  #   )
  # end

  def handle_info({:new_block, chain_id, block}, socket) do
    IO.inspect({chain_id, block})
    block_list = socket.assigns.block_list

    updated_item = Map.replace(block_list, chain_id, block)

    {:noreply, assign(socket,
      block_list: Map.merge(block_list, updated_item)
    )}
  end

  # def handle_info(pid, socket) do
  #   {:noreply, assign(
  #     socket,
  #     state: state,
  #     blocks: state.blocks,
  #     block_number: state.block.number,
  #     base_fee: state.block.base_fee
  #   )}
  # end

  defp list_chains do
    {:ok, chains} = Cachex.export(:chains)
    IO.inspect(chains)

    chains
    |> Enum.map(fn {_, cid, _, _, block} ->
      Chain.get!(cid)
      |> Map.put(:block, block)
    end)
  end
  # def handle_event("chart1_bar_clicked", %{"category" => category, "series" => series, "value" => value}=_params, socket) do
  #   bar_clicked = "You clicked: #{category} / #{series} with value #{value}"
  #   selected_bar = %{category: category, series: series}

  #   socket = assign(socket, bar_clicked: bar_clicked, selected_bar: selected_bar)

  #   {:noreply, socket}
  # end

  # def handle_event("select_state", %{"event" => event} = params, socket) do
  #   selected_event = %{selected_event: event}

  #   pool_address = "0x80c7770b4399ae22149db17e97f9fc8a10ca5100"
  #   pool_symbol = :LYXE_WETH_3000
  #   key = "LYXE_WETH_3000:"

  #   ticks =
  #     Poison.decode!(
  #       Redix.command!(:redix, ["XRANGE", "#{key}StateStream", event, event])
  #       |> Enum.at(0)
  #       |> Enum.at(1)
  #       |> Enum.at(1)
  #     )
  #     |> Enum.map(fn t -> [String.to_integer(t["tick"]), t["liquidityNet"]] end)

  #   tick_range = ticks |> Enum.map(fn [t, l] -> t end)

  #   IO.inspect(tick_range, label: "tick_range")
  #   options = socket.assigns.chart_options
  #   series = 2

  #   min_tick = -85200#Enum.min(tick_range)
  #   max_tick = 0 #Enum.max(tick_range)
  #   tick_spacing = Contract.get_tick_spacing("0x80c7770b4399ae22149db17e97f9fc8a10ca5100")

  #   {liq, data} =
  #     min_tick..max_tick
  #     |> Enum.take_every(tick_spacing)
  #     |> Enum.reduce({0, []}, fn t, {liquidity, data} ->
  #       tickRange =
  #         if Enum.member?(tick_range, t) do
  #           ticks
  #           |> Enum.find(fn [tk, l] -> tk == t end)
  #           |> Enum.at(1)
  #           # Web3x.Contract.call(pool_symbol, :ticks, [t]) |> Tuple.to_list() |> Enum.at(2)
  #         else
  #           0
  #         end

  #       liquidity = liquidity + tickRange

  #       new_data = data |> Enum.concat([[t, liquidity]])

  #       {liquidity, new_data}
  #     end)

  #   IO.inspect(data, label: "dddd")

  #   series_cols = for i <- ["liquidity"] do
  #     "Series #{i}"
  #   end

  #   test_data = Dataset.new(data, ["Category" | series_cols])

  #   options = Map.put(options, :series_columns, series_cols)

  #   socket = assign(socket, test_data: test_data, chart_options: options, selected_event: selected_event)

  #   {:noreply, socket}
  # end

  # def handle_event("select_swap", %{"event" => swap} = params, socket) do
  #   selected_swap = %{selected_swap: swap}

  #   pool_address = "0x80c7770b4399ae22149db17e97f9fc8a10ca5100"
  #   pool_symbol = :LYXE_WETH_3000
  #   key = "LYXE_WETH_3000:"

  #   block = swap |> String.split("-") |> Enum.at(0)
  #   tx_idx = swap |> String.split("-") |> Enum.at(1) |> Utils.zero_pad()

  #   tick = Redix.command!(:redix, ["HGET", "#{key}Swap:#{block}-#{tx_idx}", "tick"])

  #   IO.inspect({socket.assigns.selected_event}, label: "swap")

  #   # series_cols = for i <- ["liquidity"] do
  #   #   "Series #{i}"
  #   # end

  #   # test_data = Dataset.new(data, ["Category" | series_cols])

  #   # options = Map.put(options, :series_columns, series_cols)

  #   #socket = assign(socket, test_data: test_data, chart_options: options, selected_swap: selected_swap)

  #   {:noreply, socket}
  # end

  # def handle_event("chart_options_changed", %{}=params, socket) do
  #   socket =
  #     socket
  #     |> update_chart_options_from_params(params)
  #     |> make_test_data()

  #   {:noreply, socket}
  # end

end
