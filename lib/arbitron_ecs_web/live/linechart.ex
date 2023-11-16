defmodule ArbitronWeb.LinechartLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  import ArbitronWeb.Shared

  alias Contex.{LinePlot, PointPlot, Dataset, Plot}

  def render(assigns) do
    ~L"""
      <h3>Simple Point Plot Example</h3>
      <div class="container">
        <div class="row">
          <div class="column column-25">
            <form phx-change="chart_options_changed">
              <label for="title">Plot Title</label>
              <input type="text" name="title" id="title" placeholder="Enter title" value=<%= @chart_options.title %>>

              <label for="series">Number of series</label>
              <input type="number" name="series" id="series" placeholder="Enter #series" value=<%= @chart_options.series %>>

              <label for="points">Number of points</label>
              <input type="number" name="points" id="points" placeholder="Enter #series" value=<%= @chart_options.points %>>

              <label for="type">Type</label>
              <%= raw_select("type", "type", simple_option_list(~w(point line)), @chart_options.type) %>

              <label for="type">Smoothed</label>
              <%= raw_select("smoothed", "smoothed", yes_no_options(), @chart_options.smoothed) %>

              <label for="colour_scheme">Colour Scheme</label>
              <%= raw_select("colour_scheme", "colour_scheme", colour_options(), @chart_options.colour_scheme) %>

              <label for="legend_setting">Legend</label>
              <%= raw_select("legend_setting", "legend_setting", legend_options(), @chart_options.legend_setting) %>

              <label for="custom_x_scale">Custom X Scale</label>
              <%= raw_select("custom_x_scale", "custom_x_scale", yes_no_options(), @chart_options.custom_x_scale) %>

              <label for="custom_y_scale">Custom Y Scale</label>
              <%= raw_select("custom_y_scale", "custom_y_scale", yes_no_options(), @chart_options.custom_y_scale) %>

              <label for="custom_y_ticks">Custom Y Ticks</label>
              <%= raw_select("custom_y_ticks", "custom_y_ticks", yes_no_options(), @chart_options.custom_y_ticks) %>

              <label for="time_series">Time Series</label>
              <%= raw_select("time_series", "time_series", yes_no_options(), @chart_options.time_series) %>
            </form>
          </div>

          <div class="column">
            <%= build_pointplot(@test_data, @chart_options) %>
            <%= list_to_comma_string(@chart_options[:friendly_message]) %>
          </div>
        </div>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        chart_options: %{
          series: 4,
          points: 30,
          title: nil,
          type: "point",
          smoothed: "yes",
          colour_scheme: "default",
          legend_setting: "legend_none",
          custom_x_scale: "no",
          custom_y_scale: "no",
          custom_y_ticks: "no",
          time_series: "no"
        }
      )
      |> assign(prev_series: 0, prev_points: 0, prev_time_series: nil)
      |> make_test_data()

    {:ok, socket}
  end

  def handle_event("chart_options_changed", %{} = params, socket) do
    socket =
      socket
      |> update_chart_options_from_params(params)
      |> make_test_data()

    {:noreply, socket}
  end

  def build_pointplot(dataset, chart_options) do
    y_tick_formatter =
      case chart_options.custom_y_ticks do
        "yes" -> &custom_axis_formatter/1
        _ -> nil
      end

    module =
      case chart_options.type do
        "line" -> LinePlot
        _ -> PointPlot
      end

    custom_x_scale = make_custom_x_scale(chart_options)
    custom_y_scale = make_custom_y_scale(chart_options)

    options = [
      mapping: %{x_col: "X", y_cols: chart_options.series_columns},
      colour_palette: lookup_colours(chart_options.colour_scheme),
      custom_x_scale: custom_x_scale,
      custom_y_scale: custom_y_scale,
      custom_y_formatter: y_tick_formatter,
      smoothed: chart_options.smoothed == "yes"
    ]

    plot_options =
      case chart_options.legend_setting do
        "legend_right" -> %{legend_setting: :legend_right}
        "legend_top" -> %{legend_setting: :legend_top}
        "legend_bottom" -> %{legend_setting: :legend_bottom}
        _ -> %{}
      end

    plot =
      Plot.new(dataset, module, 600, 400, options)
      |> Plot.titles(chart_options.title, nil)
      |> Plot.plot_options(plot_options)

    Plot.to_svg(plot)
  end

  def make_test_data2(socket) do
    uni = [
      {18574512, 1972.858721286259},
      {18574519, 1972.8703022816633},
      {18574525, 1972.8924441936754},
      {18574532, 1972.8836005568967},
      {18574533, 1973.0299244859975},
      {18574535, 1973.7680849843132},
      {18574536, 1973.7889258240991},
      {18574536, 1973.7963081631106},
      {18574539, 1973.7788227828712},
      {18574542, 1973.774480850568},
      {18574547, 1973.6819071127718},
      {18574549, 1973.6920796188126},
      {18574549, 1973.6817462868594},
      {18574555, 1973.5501947706637},
      {18574558, 1973.5612676135104},
      {18574561, 1974.2404613498318},
      {18574562, 1974.2544315601904},
      {18574565, 1974.4691554512024},
      {18574565, 1974.5060736274716},
      {18574566, 1973.9389651056335},
      {18574567, 1973.94172999091},
      {18574569, 1973.9174518509724},
      {18574596, 1973.6491459635101},
      {18574596, 1974.0920947031568},
      {18574604, 1974.3116495558695},
      {18574625, 1974.300315175217},
      {18574626, 1974.3150817640708},
      {18574627, 1974.4050376433127},
      {18574630, 1974.5527099272203},
      {18574634, 1974.5564018048647},
      {18574640, 1974.8148418163084},
      {18574648, 1974.9867850064559},
      {18574649, 1975.0157839679282},
      {18574655, 1975.1670399495758},
      {18574662, 1974.858856813761},
      {18574664, 1974.7909355718562},
      {18574667, 1974.8250233129238},
      {18574678, 1974.8353612877847},
      {18574683, 1974.8209062339813},
      {18574684, 1974.962454879909},
      {18574687, 1974.9727932138285},
      {18574689, 1975.1495294628462},
      {18574690, 1974.9622248513178},
      {18574696, 1974.8630564723562},
      {18574698, 1974.6979771401682},
      {18574706, 1974.5880394375608},
      {18574710, 1974.589637711788},
      {18574721, 1974.8111583872067}
    ]

    sushi = [
      {18574515, 1972.3815668870818},
      {18574517, 1972.9511424021891},
      {18574523, 1972.950561384671},
      {18574539, 1973.1333338868335},
      {18574542, 1973.2398585217384},
      {18574551, 1973.3527948597798},
      {18574569, 1973.3812786823855},
      {18574575, 1973.3961456073953},
      {18574587, 1973.9145890400666},
      {18574637, 1974.0821633451333},
      {18574645, 1974.2039904539351},
      {18574667, 1974.2254986609835},
      {18574701, 1974.3109696101747},
      {18574708, 1974.6166613874243},
      {18574722, 1977.470994829981},
      {18574723, 1977.4101584343912},
      {18574729, 1977.4399059445175},
      {18574735, 1977.4387881510738},
      {18574739, 1976.9726713499617},
      {18574740, 1976.8481237977965},
      {18574751, 1976.557659884592},
      {18574761, 1976.6839737357038},
      {18574768, 1976.2729639667436},
      {18574768, 1976.2468910038726},
      {18574787, 1975.3886822638808},
      {18574787, 1974.8989256567413},
      {18574788, 1975.585362849577},
      {18574789, 1975.2475841004425},
      {18574793, 1975.281781013795},
      {18574808, 1975.566766799826},
      {18574823, 1975.515422399216},
      {18574836, 1977.607958593445},
      {18574845, 1976.4806386759515},
      {18574896, 1976.304950698545},
      {18574938, 1976.5153813924203},
      {18574957, 1976.4896904845937},
      {18574992, 1976.4173633695204},
      {18575001, 1976.349758117776},
      {18575040, 1976.3173693900214},
      {18575061, 1978.438185502181},
      {18575106, 1978.4608570427283},
      {18575107, 1978.5178072160995},
      {18575139, 1979.0818624406918},
      {18575160, 1979.76651863611},
      {18575185, 1979.759677129306},
      {18575199, 1980.3253198498992},
      {18575234, 1980.6106683357323},
      {18575243, 1980.9406247625514}
    ]

    data = [{1, 1}, {2, 2}]
    ds = Dataset.new(data, ["x", "y"])
  end

  defp make_test_data(socket) do
    options = socket.assigns.chart_options
    time_series = options.time_series == "yes"
    prev_series = socket.assigns.prev_series
    prev_points = socket.assigns.prev_points
    prev_time_series = socket.assigns.prev_time_series
    series = options.series
    points = options.points

    uni = [
      {18574512, 1972.858721286259},
      {18574519, 1972.8703022816633},
      {18574525, 1972.8924441936754},
      {18574532, 1972.8836005568967},
      {18574533, 1973.0299244859975},
      {18574535, 1973.7680849843132},
      {18574536, 1973.7889258240991},
      {18574536, 1973.7963081631106},
      {18574539, 1973.7788227828712},
      {18574542, 1973.774480850568},
      {18574547, 1973.6819071127718},
      {18574549, 1973.6920796188126},
      {18574549, 1973.6817462868594},
      {18574555, 1973.5501947706637},
      {18574558, 1973.5612676135104},
      {18574561, 1974.2404613498318},
      {18574562, 1974.2544315601904},
      {18574565, 1974.4691554512024},
      {18574565, 1974.5060736274716},
      {18574566, 1973.9389651056335},
      {18574567, 1973.94172999091},
      {18574569, 1973.9174518509724},
      {18574596, 1973.6491459635101},
      {18574596, 1974.0920947031568},
      {18574604, 1974.3116495558695},
      {18574625, 1974.300315175217},
      {18574626, 1974.3150817640708},
      {18574627, 1974.4050376433127},
      {18574630, 1974.5527099272203},
      {18574634, 1974.5564018048647},
      {18574640, 1974.8148418163084},
      {18574648, 1974.9867850064559},
      {18574649, 1975.0157839679282},
      {18574655, 1975.1670399495758},
      {18574662, 1974.858856813761},
      {18574664, 1974.7909355718562},
      {18574667, 1974.8250233129238},
      {18574678, 1974.8353612877847},
      {18574683, 1974.8209062339813},
      {18574684, 1974.962454879909},
      {18574687, 1974.9727932138285},
      {18574689, 1975.1495294628462},
      {18574690, 1974.9622248513178},
      {18574696, 1974.8630564723562},
      {18574698, 1974.6979771401682},
      {18574706, 1974.5880394375608},
      {18574710, 1974.589637711788},
      {18574721, 1974.8111583872067}
    ]

    sushi = [
      {18574515, 1972.3815668870818},
      {18574517, 1972.9511424021891},
      {18574523, 1972.950561384671},
      {18574539, 1973.1333338868335},
      {18574542, 1973.2398585217384},
      {18574551, 1973.3527948597798},
      {18574569, 1973.3812786823855},
      {18574575, 1973.3961456073953},
      {18574587, 1973.9145890400666},
      {18574637, 1974.0821633451333},
      {18574645, 1974.2039904539351},
      {18574667, 1974.2254986609835},
      {18574701, 1974.3109696101747},
      {18574708, 1974.6166613874243},
      {18574722, 1977.470994829981},
      {18574723, 1977.4101584343912},
      {18574729, 1977.4399059445175},
      {18574735, 1977.4387881510738},
      {18574739, 1976.9726713499617},
      {18574740, 1976.8481237977965},
      {18574751, 1976.557659884592},
      {18574761, 1976.6839737357038},
      {18574768, 1976.2729639667436},
      {18574768, 1976.2468910038726},
      {18574787, 1975.3886822638808},
      {18574787, 1974.8989256567413},
      {18574788, 1975.585362849577},
      {18574789, 1975.2475841004425},
      {18574793, 1975.281781013795},
      {18574808, 1975.566766799826},
      {18574823, 1975.515422399216},
      {18574836, 1977.607958593445},
      {18574845, 1976.4806386759515},
      {18574896, 1976.304950698545},
      {18574938, 1976.5153813924203},
      {18574957, 1976.4896904845937},
      {18574992, 1976.4173633695204},
      {18575001, 1976.349758117776},
      {18575040, 1976.3173693900214},
      {18575061, 1978.438185502181},
      {18575106, 1978.4608570427283},
      {18575107, 1978.5178072160995},
      {18575139, 1979.0818624406918},
      {18575160, 1979.76651863611},
      {18575185, 1979.759677129306},
      {18575199, 1980.3253198498992},
      {18575234, 1980.6106683357323},
      {18575243, 1980.9406247625514}
    ]

    needs_update =
      prev_series != series or prev_points != points or prev_time_series != time_series

    data =
      for i <- 1..points do
        x = i * 5 + random_within_range(0.0, 3.0)

        series_data =
          for s <- 1..series do
            val = s * 8.0 + random_within_range(x * (0.1 * s), x * (0.35 * s))
            # simulate nils in data
            case s == 2 and ((i > 3 and i < 6) or (i > 7 and i < 10)) do
              true -> nil
              _ -> val
            end
          end

        [calc_x(x, i, time_series) | series_data]
      end

    series_cols = ["x", "y"]
      # for s <- 1..series do
      #   "Series #{s}"
      # end

      IO.inspect(data, label: "data")
    test_data =
      case needs_update do
        true -> Dataset.new(uni, series_cols)
        _ -> socket.assigns.test_data
      end
      IO.inspect(series_cols, label: "series_cols")
      IO.inspect(test_data, label: "test_data")
    options = Map.put(options, :series_columns, series_cols)

    assign(socket,
      test_data: test_data,
      chart_options: options,
      prev_series: series,
      prev_points: points,
      prev_time_series: time_series
    )
  end

  @date_min ~N{2019-10-01 10:00:00}
  @interval_seconds 600
  defp calc_x(x, _, false), do: x

  defp calc_x(_, i, _) do
    NaiveDateTime.add(@date_min, i * @interval_seconds)
  end

  defp random_within_range(min, max) do
    diff = max - min
    :rand.uniform() * diff + min
  end

  def custom_axis_formatter(value) when is_float(value) do
    "V #{:erlang.float_to_binary(value / 1_000.0, decimals: 2)}K"
  end

  def custom_axis_formatter(value) do
    "V #{value}"
  end

  defp make_custom_x_scale(%{custom_x_scale: x} = _chart_options) when x != "yes", do: nil

  defp make_custom_x_scale(chart_options) do
    points = chart_options.points

    case chart_options.time_series == "yes" do
      true ->
        Contex.TimeScale.new()
        |> Contex.TimeScale.domain(
          @date_min,
          NaiveDateTime.add(@date_min, trunc(points * 1.2 * @interval_seconds))
        )

      _ ->
        Contex.ContinuousLinearScale.new()
        |> Contex.ContinuousLinearScale.domain(0, 100)
        |> Contex.ContinuousLinearScale.interval_count(20)
    end
  end

  defp make_custom_y_scale(%{custom_y_scale: x} = _chart_options) when x != "yes", do: nil

  defp make_custom_y_scale(_chart_options) do
    Contex.ContinuousLinearScale.new()
    |> Contex.ContinuousLinearScale.domain(0, 100)
    |> Contex.ContinuousLinearScale.interval_count(20)
  end
end
