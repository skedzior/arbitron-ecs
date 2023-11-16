defmodule Arbitron.Exchanges.Kucoin do
  @endpoint "https://api.kucoin.com"
  @api_key "63b5cd6f8f1a4900011c36f9"
  @api_secret "d3c693ca-42ec-442c-aea3-ae096fa8d270"
  @api_passphrase "Ku$293854$coin"
  @key_base "CEX:Kucoin"

  def get_public_token do
    resp = HTTPoison.post!("https://api.kucoin.com/api/v1/bullet-public", [])

    response =
      resp.body
      |> Poison.decode!()

    response["data"]["token"]
  end

  def full_orderbook(symbol) do
    url = "/api/v3/market/orderbook/level2?symbol=#{symbol}"

    case prepare_request(url) do
      {:error, _} = error ->
        error

      {:ok, headers} ->
        HTTPoison.get("#{@endpoint}#{url}", headers)
        |> parse_response

        # |> create_book()
    end
  end

  def get_klines(symbol, duration \\ "1hour") do
    # &startAt=1566703297&endAt=1566789757"
    url = "/api/v1/market/candles?type=#{duration}&symbol=#{symbol}"
    # 1min, 3min, 5min, 15min, 30min, 1hour, 2hour, 4hour, 6hour, 8hour, 12hour, 1day, 1week
    HTTPoison.get("#{@endpoint}#{url}") |> parse_response
  end

  def get_pairs do
    data =
      HTTPoison.get("#{@endpoint}/api/v2/symbols")
      |> parse_response

    # Enum.map(data, fn c ->
    #   Redix.command(:redix, [
    #     "JSON.SET",
    #     "CEX:Kucoin:pair:#{c["symbol"]}:detail",
    #     "$",
    #     Poison.encode!(c)
    #   ])
    # end)
  end

  def get_pair_decimals(symbol) do
    key = "#{@key_base}:pair:#{String.upcase(symbol)}:detail"

    Redix.command!(:redix, ["JSON.GET", key, "$.quoteIncrement"])
    |> Poison.decode!()
    |> Enum.at(0)
    |> String.split(".")
    |> Enum.at(1)
    |> String.length()
  end

  def get_currency(currency) do
    url = "/api/v2/currencies/#{currency}"

    data =
      HTTPoison.get("#{@endpoint}#{url}")
      |> parse_response

    Redix.command(:redix, [
      "JSON.SET",
      "#{@key_base}:token:#{currency}:detail",
      "$",
      Poison.encode!(data)
    ])
  end

  def get_currencies do
    HTTPoison.get("#{@endpoint}/api/v1/currencies")
    |> parse_response
  end

  def get_price_usd(symbol) do
    url = "/api/v1/prices?currencies=#{symbol}"

    data =
      HTTPoison.get("#{@endpoint}#{url}")
      |> parse_response
  end

  def get_symbols_by_currency(currency) do
    get_pairs()
    |> Enum.filter(&(&1["baseCurrency"] == currency or &1["quoteCurrency"] == currency))
  end

  def get_symbols_by_base(currency) do
    get_pairs()
    |> Enum.filter(&(&1["baseCurrency"] == currency))
  end

  def update_orderbook(message) do
    message.data.asks
    |> Poison.decode!()
    |> Enum.map(fn [p, q, _s] -> Utils.zrem_zadd("asks", p, q) end)

    message.data.bids
    |> Poison.decode!()
    |> Enum.map(fn [p, q, _s] -> Utils.zrem_zadd("bids", p, q) end)

    # calc_depth()

    Redix.command!(:redix, [
      "SET",
      "#{@key_base}:pair:LYXE-USDT:book:sequenceEnd",
      message.data.sequenceStart
    ])
  end

  def create_book(book) do
    Redix.command!(:redix, [
      "DEL",
      "#{@key_base}:pair:LYXE-USDT:book:asks",
      "#{@key_base}:pair:LYXE-USDT:book:bids"
    ])

    create_side("asks", book)
    create_side("bids", book)

    Redix.command!(:redix, [
      "SET",
      "#{@key_base}:pair:LYXE-USDT:book:sequenceStart",
      book["sequence"]
    ])
  end

  def create_side(side, book) do
    orders =
      Enum.reduce(book[side], [], fn [p, q], acc ->
        acc
        |> Enum.concat([p])
        # "#{q}:#{Utils.parse_string(p) * Utils.parse_string(q)}"])
        |> Enum.concat([q])
      end)

    Redix.command!(
      :redix,
      Enum.concat(
        [
          "ZADD",
          "#{@key_base}:pair:LYXE-USDT:book:#{side}"
        ],
        orders
      )
    )
  end

  def prepare_request(url) do
    ts = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    signature =
      :crypto.mac(:hmac, :sha256, @api_secret, "#{ts}GET#{url}")
      |> Base.encode64()

    passphrase =
      :crypto.mac(:hmac, :sha256, @api_secret, @api_passphrase)
      |> Base.encode64()

    headers = [
      {"KC-API-SIGN", signature},
      {"KC-API-TIMESTAMP", ts},
      {"KC-API-KEY", @api_key},
      {"KC-API-PASSPHRASE", passphrase},
      {"KC-API-KEY-VERSION", "2"}
    ]

    {:ok, headers}
  end

  def parse_response({:ok, response}) do
    response.body
    |> Poison.decode()
    |> parse_response_body!
  end

  def parse_response({:error, err}) do
    {:error, {:http_error, err}}
  end

  def parse_response_body({:ok, data}) do
    case data do
      %{"code" => _c, "msg" => _m} = error -> {:error, error}
      _ -> {:ok, data}
    end
  end

  def parse_response_body!({:ok, data}) do
    case data do
      %{"code" => _c, "msg" => _m} = error -> {:error, error}
      _ -> data["data"]
    end
  end
end
