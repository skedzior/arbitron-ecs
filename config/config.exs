# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :arbitron_ecs,
  namespace: Arbitron,
  ecto_repos: [Arbitron.Repo]

# Configures the endpoint
config :arbitron_ecs, ArbitronWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ArbitronWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Arbitron.PubSub,
  live_view: [signing_salt: "FdDYbCxV"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :arbitron_ecs, Arbitron.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :blockchain,
  routers: [
    %{
      name: "UniversalRouter_Dep",
      dex: "Uniswap",
      address: "0x3fc91a3afd70395cd496c647d5a6cc9d4b2b7fad",
      type: :universal_router
    },
    %{
      name: "UniversalRouter",
      dex: "Uniswap",
      address: "0xef1c6e67703c7bd7107eed8303fbe6ec2554bf6b",
      type: :universal_router
    },
    # %{
    #   name: "AggregationRouterV5",
    #   dex: "1Inch",
    #   address: "0x1111111254eeb25477b68fb85ed929f73a960582"
    # }
  ],
  chains: [
    %{
      id: 1,
      name: "Ethereum",
      symbol: "ETH",
      providers: [],
      dexes: [
        %{
          name: "UniswapV2",
          router_address: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
          factory_address: "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
        },
        %{
          name: "SushiSwap",
          router_address: "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F",
          factory_address: "0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac",
        }
      ]
    }
  ]

config :watch_list,
  pairs: [
    %{
      name: "LYXe_ETH",
      address: "0xd583D0824Ed78767E0E35B9bF7a636c81C665Aa8",
      symbol: "LYXe_ETH",
      dex: "Uniswap",
      fee: 30
    },
    %{
      name: "PEPE_ETH",
      address: "0xa43fe16908251ee70ef74718545e4fe6c5ccec9f",
      symbol: "PEPE_ETH",
      dex: "Uniswap",
      fee: 30
    }
  ],
  pools: [
    # %{
    #   name: "LYXe_ETH_3000",
    #   address: "0x80C7770B4399AE22149db17e97F9FC8a10ca5100",
    #   symbol: "LYXe_WETH",
    #   dex: "Uniswap",
    #   fee: 3000
    # },
    # %{
    #   name: "LYXe_ETH_10000",
    #   address: "0x2418C488Bc4b0c3cF1EdFC7f6B572847f12eD24F",
    #   symbol: "LYXe_WETH",
    #   dex: "Uniswap",
    #   fee: 10000
    # },
    %{
      name: "PEPE_ETH_3000",
      address: "0x11950d141ecb863f01007add7d1a342041227b58",
      symbol: "PEPE_ETH",
      dex: "Uniswap",
      fee: 3000
    }
  ]

config :rpc_providers,
  eth:
    %{
      name: "alchemy",
      ws_url: "wss://eth-mainnet.g.alchemy.com/v2/#{INSERT_YOUR_KEY}",
      url: "https://eth-mainnet.alchemyapi.io/v2/#{INSERT_YOUR_KEY}"
    }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
