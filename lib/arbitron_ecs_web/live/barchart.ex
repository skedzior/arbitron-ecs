defmodule ArbitronWeb.BarChartLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  import ArbitronWeb.Shared

  alias Contex.{BarChart, Plot, Dataset}

  def render(assigns) do
    ~L"""
      <div class="container">
        <div class="row">
          <div class="column column-25">
            <form phx-change="chart_options_changed">
              <label for="title">Plot Title</label>
              <input type="text" name="title" id="title" placeholder="Enter title" value=<%= @chart_options.title %>>
              <label for="title">Sub Title</label>
              <input type="text" name="subtitle" id="subtitle" placeholder="Enter subtitle" value=<%= @chart_options.subtitle %>>
              <label for="type">Type</label>
              <%= raw_select("type", "type", chart_type_options(), Atom.to_string(@chart_options.type)) %>
              <label for="orientation">Orientation</label>
              <%= raw_select("orientation", "orientation", chart_orientation_options(), Atom.to_string(@chart_options.orientation)) %>
              <label for="colour_scheme">Colour Scheme</label>
              <%= raw_select("colour_scheme", "colour_scheme", colour_options(), @chart_options.colour_scheme) %>
              <label for="legend_setting">Legend</label>
              <%= raw_select("legend_setting", "legend_setting", legend_options(), @chart_options.legend_setting) %>
              <label for="show_axislabels">Show Axis Labels</label>
              <%= raw_select("show_axislabels", "show_axislabels", yes_no_options(), @chart_options.show_axislabels) %>
              <label for="show_data_labels">Show Data Labels</label>
              <%= raw_select("show_data_labels", "show_data_labels", yes_no_options(), @chart_options.show_data_labels) %>
              <label for="custom_value_scale">Custom Value Scale</label>
              <%= raw_select("custom_value_scale", "custom_value_scale", yes_no_options(), @chart_options.custom_value_scale) %>
              <label for="show_selected">Show Clicked Bar</label>
              <%= raw_select("show_selected", "show_selected", yes_no_options(), @chart_options.show_selected) %>
            </form>
          </div>
          <div class="column column-75">
            <%= basic_plot(@test_data, @chart_options, @selected_bar) %>
            <p><em><%= @bar_clicked %></em></p>
            <%= list_to_comma_string(@chart_options[:friendly_message]) %>
          </div>
        </div>
      </div>
    """

  end

  def mount(_params, _session, socket) do


    socket =
      socket
      |> assign(chart_options: %{
            categories: 10,
            series: 3,
            type: :stacked,
            orientation: :horizontal,
            show_data_labels: "no",
            show_selected: "no",
            show_axislabels: "no",
            custom_value_scale: "no",
            title: nil,
            subtitle: nil,
            colour_scheme: "themed",
            legend_setting: "legend_none",
        })
      |> assign(bar_clicked: "Click a bar. Any bar", selected_bar: nil)
      |> make_test_data3()

    {:ok, socket}

  end

  def handle_info({:block, block}, socket) do
    IO.inspect(block.number)
    {:noreply, assign(
      socket,
      block_number: block.number,
      base_fee: block.base_fee
    )}
  end

  def handle_event("chart_options_changed", %{}=params, socket) do
    socket =
      socket
      |> update_chart_options_from_params(params)
      |> make_test_data()

    {:noreply, socket}
  end

  def handle_event("chart1_bar_clicked", %{"category" => category, "series" => series, "value" => value}=_params, socket) do
    bar_clicked = "You clicked: #{category} / #{series} with value #{value}"
    selected_bar = %{category: category, series: series}

    socket = assign(socket, bar_clicked: bar_clicked, selected_bar: selected_bar)

    {:noreply, socket}
  end

  def basic_plot(test_data, chart_options, selected_bar) do

    selected_item = case chart_options.show_selected do
      "yes" -> selected_bar
      _ -> nil
    end

    custom_value_scale = make_custom_value_scale(chart_options)

    options = [
      mapping: %{category_col: "Category", value_cols: chart_options.series_columns},
      type: chart_options.type,
      data_labels: (chart_options.show_data_labels == "yes"),
      orientation: chart_options.orientation,
      phx_event_handler: "chart1_bar_clicked",
      custom_value_scale: custom_value_scale,
      colour_palette: ["b3cde3", "ccebc5"],
      select_item: selected_item,
      padding: 0
    ]

    plot_options = case chart_options.legend_setting do
      "legend_right" -> %{legend_setting: :legend_right}
      "legend_top" -> %{legend_setting: :legend_top}
      "legend_bottom" -> %{legend_setting: :legend_bottom}
      _ -> %{}
    end

    {x_label, y_label} = case chart_options.show_axislabels do
      "yes" -> {"x-axis", "y-axis"}
      _ -> {nil, nil}
    end

    # barchart = BarChart.new(test_data, colour_palette: ["000000", "ffffff"])

    plot =  # Plot.new(500, 400, barchart)
      Plot.new(test_data, BarChart, 800, 800, options)
      |> Plot.titles(chart_options.title, chart_options.subtitle)
      |> Plot.axis_labels(x_label, y_label)
      |> Plot.plot_options(plot_options)

    Plot.to_svg(plot)
  end

  defp make_test_data2(socket) do
    options = socket.assigns.chart_options
    series = 2
    categories = ["token0", "token1"]
    raw_data = [
      [246000, 0.0, 2.2543964225468193e18],
      [246200, 0.0, 2.277052344816815e18],
      [246400, 0.0, 2.2999359514500436e18],
      [246600, 0.0, 2.323049530597333e18],
      [246800, 0.0, 2.346395393404855e18],
      [247000, 0.0, 2.3699758742448727e18],
      [247200, 0.0, 2.393793330949282e18],
      [247400, 0.0, 2.4178501450454994e18],
      [247600, 0.0, 2.4421487219944417e18],
      [247800, 0.0, 2.4666914914310175e18],
      [248000, 0.0, 2.491480907407281e18],
      [248200, 0.0, 2.516519448637535e18],
      [248400, 0.0, 2.541809618746538e18],
      [248600, 0.0, 2.5673539465193354e18],
      [248800, 0.0, 2.5931549861546696e18],
      [249000, 0.0, 2.619215317519987e18],
      [249200, 0.0, 2.6455375464095447e18],
      [249400, 0.0, 2.6721243048049797e18],
      [249600, 0.0, 2.6989782511384074e18],
      [249800, 0.0, 7.696067180628695e19],
      [250000, 0.0, 7.773410055237994e19],
      [250200, 0.0, 7.851530199602556e19],
      [250400, 0.0, 7.93043542502045e19],
      [250600, 0.0, 8.010133621291283e19],
      [250800, 0.0, 8.09063275750414e19],
      [251000, 0.0, 8.171940882834715e19],
      [251200, 0.0, 8.254066127349868e19],
      [251400, 0.0, 8.337016702822231e19],
      [251600, 0.0, 8.42080090354818e19],
      [251800, 0.0, 8.505427107180069e19],
      [252000, 0.0, 8.59090377556302e19],
      [252200, 0.0, 8.67723945557975e19],
      [252400, 0.0, 8.76444278000732e19],
      [252600, 683685373.8575598, 2.3943738292974473e19],
      [252800, 930360892.8945891, 0.0],
      [253000, 921104107.8582617, 0.0],
      [253200, 3107594962.113372, 0.0],
      [253400, 3076675413.834849, 0.0],
      [253600, 3046063504.8972244, 0.0],
      [253800, 3015756174.3900633, 0.0],
      [254000, 2985750391.8582587, 0.0],
      [254200, 2956043156.9984384, 0.0],
      [254400, 2926631499.3595243, 0.0],
      [254600, 2897512478.0452843, 0.0],
      [254800, 2868683181.4204745, 0.0],
      [255000, 2840140726.8197527, 0.0],
      [255200, 2811882260.2591867, 0.0],
      [255400, 2783904956.1511354, 0.0],
      [255600, 2756206017.021774, 0.0],
      [255800, 2728782673.2309003, 0.0],
      [256000, 2701632182.6955466, 0.0],
      [256200, 2674751830.615587, 0.0],
      [256400, 2648138929.202113, 0.0],
      [256600, 2621790817.40895, 0.0],
      [256800, 6167385456.769041, 0.0],
      [257000, 6106021998.947976, 0.0],
      [257200, 4247600400.3881526, 0.0],
      [257400, 4205338172.7655783, 0.0],
      [257600, 3457563694.3548746, 0.0],
      [257800, 3423162072.2397437, 0.0],
      [258000, 3389102734.9553795, 0.0],
      [258200, 3330224569.472698, 0.0],
      [258400, 3297089929.788507, 0.0],
      [258600, 3264284968.8764462, 0.0],
      [258800, 3231806406.5411367, 0.0],
      [259000, 3199650995.2240024, 0.0],
      [259200, 3167815519.6786222, 0.0],
      [259400, 3136296796.649391, 0.0],
      [259600, 3105091674.552676, 0.0]
    ]

    data = raw_data
    |> Enum.map(fn [t, a0, a1] ->
      ["#{t}", a0, a1]
    end)

    series_cols = for i <- ["token0", "token1"] do
      "Series #{i}"
    end

    test_data = Dataset.new(data, ["Category" | series_cols])
    IO.inspect(test_data)
    options = Map.put(options, :series_columns, series_cols)

    assign(socket, test_data: test_data, chart_options: options)
  end

  defp make_test_data3(socket) do
    options = socket.assigns.chart_options
    series = 2
    categories = ["token0", "token1"]
    raw_data = [
      [246000, 0, 1021700893270807],
      [246200, 0, 1021700893270807],
      [246400, 0, 1021700893270807],
      [246600, 0, 1021700893270807],
      [246800, 0, 1021700893270807],
      [247000, 0, 1021700893270807],
      [247200, 0, 1021700893270807],
      [247400, 0, 1021700893270807],
      [247600, 0, 1021700893270807],
      [247800, 0, 1021700893270807],
      [248000, 0, 1021700893270807],
      [248200, 0, 1021700893270807],
      [248400, 0, 1021700893270807],
      [248600, 0, 1021700893270807],
      [248800, 0, 1021700893270807],
      [249000, 0, 1021700893270807],
      [249200, 0, 1021700893270807],
      [249400, 0, 1021700893270807],
      [249600, 0, 1021700893270807],
      [249800, 0, 28843669494406812],
      [250000, 0, 28843669494406812],
      [250200, 0, 28843669494406812],
      [250400, 0, 28843669494406812],
      [250600, 0, 28843669494406812],
      [250800, 0, 28843669494406812],
      [251000, 0, 28843669494406812],
      [251200, 0, 28843669494406812],
      [251400, 0, 28843669494406812],
      [251600, 0, 28843669494406812],
      [251800, 0, 28843669494406812],
      [252000, 0, 28843669494406812],
      [252200, 0, 28843669494406812],
      [252400, 0, 28843669494406812],
      [252600, 0, 28843669494406812],
      [252700, 0, 576873389888136.2],
      [252800, 2.8266796104518676e16, 0],
      [253000, 28843669494406812, 0],
      [253200, 98289907830585788, 0],
      [253400, 98289907830585788, 0],
      [253600, 98289907830585788, 0],
      [253800, 98289907830585788, 0],
      [254000, 98289907830585788, 0],
      [254200, 98289907830585788, 0],
      [254400, 98289907830585788, 0],
      [254600, 98289907830585788, 0],
      [254800, 98289907830585788, 0],
      [255000, 98289907830585788, 0],
      [255200, 98289907830585788, 0],
      [255400, 98289907830585788, 0],
      [255600, 98289907830585788, 0],
      [255800, 98289907830585788, 0],
      [256000, 98289907830585788, 0],
      [256200, 98289907830585788, 0],
      [256400, 98289907830585788, 0],
      [256600, 98289907830585788, 0],
      [256800, 233536469144605293, 0],
      [257000, 233536469144605293, 0],
      [257200, 164090230808426317, 0],
      [257400, 164090230808426317, 0],
      [257600, 136268262207290312, 0],
      [257800, 136268262207290312, 0],
      [258000, 136268262207290312, 0],
      [258200, 135246561314019505, 0],
      [258400, 135246561314019505, 0],
      [258600, 135246561314019505, 0],
      [258800, 135246561314019505, 0],
      [259000, 135246561314019505, 0],
      [259200, 135246561314019505, 0],
      [259400, 135246561314019505, 0],
      [259600, 135246561314019505, 0],
      [259800, 0, 0]
    ]

    data = raw_data
    |> Enum.map(fn [t, a0, a1] ->
      ["#{t}", a0, a1]
    end)

    series_cols = for i <- ["token0", "token1"] do
      "Series #{i}"
    end

    test_data = Dataset.new(data, ["Category" | series_cols])
    IO.inspect(test_data)
    options = Map.put(options, :series_columns, series_cols)

    assign(socket, test_data: test_data, chart_options: options)
  end

  defp make_test_data(socket) do
    options = socket.assigns.chart_options
    series = 1
    raw_data = [
      [246000, 1021700893270807],
      [246200, 1021700893270807],
      [246400, 1021700893270807],
      [246600, 1021700893270807],
      [246800, 1021700893270807],
      [247000, 1021700893270807],
      [247200, 1021700893270807],
      [247400, 1021700893270807],
      [247600, 1021700893270807],
      [247800, 1021700893270807],
      [248000, 1021700893270807],
      [248200, 1021700893270807],
      [248400, 1021700893270807],
      [248600, 1021700893270807],
      [248800, 1021700893270807],
      [249000, 1021700893270807],
      [249200, 1021700893270807],
      [249400, 1021700893270807],
      [249600, 1021700893270807],
      [249800, 28843669494406812],
      [250000, 28843669494406812],
      [250200, 28843669494406812],
      [250400, 28843669494406812],
      [250600, 28843669494406812],
      [250800, 28843669494406812],
      [251000, 28843669494406812],
      [251200, 28843669494406812],
      [251400, 28843669494406812],
      [251600, 28843669494406812],
      [251800, 28843669494406812],
      [252000, 28843669494406812],
      [252200, 28843669494406812],
      [252400, 28843669494406812],
      [252600, 28843669494406812],
      [252800, 28843669494406812],
      [253000, 28843669494406812],
      [253200, 98289907830585788],
      [253400, 98289907830585788],
      [253600, 98289907830585788],
      [253800, 98289907830585788],
      [254000, 98289907830585788],
      [254200, 98289907830585788],
      [254400, 98289907830585788],
      [254600, 98289907830585788],
      [254800, 98289907830585788],
      [255000, 98289907830585788],
      [255200, 98289907830585788],
      [255400, 98289907830585788],
      [255600, 98289907830585788],
      [255800, 98289907830585788],
      [256000, 98289907830585788],
      [256200, 98289907830585788],
      [256400, 98289907830585788],
      [256600, 98289907830585788],
      [256800, 233536469144605293],
      [257000, 233536469144605293],
      [257200, 164090230808426317],
      [257400, 164090230808426317],
      [257600, 136268262207290312],
      [257800, 136268262207290312],
      [258000, 136268262207290312],
      [258200, 135246561314019505],
      [258400, 135246561314019505],
      [258600, 135246561314019505],
      [258800, 135246561314019505],
      [259000, 135246561314019505],
      [259200, 135246561314019505],
      [259400, 135246561314019505],
      [259600, 135246561314019505]
    ]

    data =
      raw_data
      |> Enum.map(fn [left, right] ->
        [left, right]
      end)

    series_cols = for i <- 1..series do
      "Series #{i}"
    end

    test_data = Dataset.new(data, ["Category" | series_cols])

    options = Map.put(options, :series_columns, series_cols)

    assign(socket, test_data: test_data, chart_options: options)
  end

  defp random_within_range(min, max) do
    diff = max - min
    (:rand.uniform() * diff) + min
  end

  defp make_custom_value_scale(%{custom_value_scale: x}=_chart_options) when x != "yes", do: nil
  defp make_custom_value_scale(_chart_options) do
    Contex.ContinuousLinearScale.new()
    |> Contex.ContinuousLinearScale.domain(0, 500)
    |> Contex.ContinuousLinearScale.interval_count(25)
  end
end
