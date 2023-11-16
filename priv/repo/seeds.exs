# Script for populating the database. You can run it as: mix run priv/repo/seeds.exs

chains = [
  [
    chain_id: 1,
    name: "Ethereum",
    symbol: "ETH",
    native_currency: "ETH",
    block_explorer: "https://etherscan.io/"
  ],
  [
    chain_id: 56,
    name: "BNB Chain",
    symbol: "BSC",
    native_currency: "BNB",
    block_explorer: "https://bscscan.com/"
  ],
  [
    chain_id: 137,
    name: "Polygon",
    symbol: "MATIC",
    native_currency: "MATIC",
    block_explorer: "https://polygonscan.com/"
  ],
  [
    chain_id: 42161,
    name: "Arbitrum",
    symbol: "ARB",
    native_currency: "ETH",
    block_explorer: "https://optimistic.etherscan.io/"
  ],
  [
    chain_id: 10,
    name: "Optimism",
    symbol: "OP",
    native_currency: "ETH",
    block_explorer: "https://optimistic.etherscan.io/"
  ],
  [
    chain_id: 250,
    name: "Fantom",
    symbol: "FTM",
    native_currency: "FTM",
    block_explorer: "https://ftmscan.com/"
  ],
  [
    chain_id: 43114,
    name: "Avalance",
    symbol: "AVAX",
    native_currency: "AVAX",
    block_explorer: "https://snowtrace.io/"
  ],
  [
    chain_id: 8453,
    name: "Base",
    symbol: "Base",
    native_currency: "ETH",
    block_explorer: "https://basescan.org"
  ]
]

providers = [
  [
    chain_id: 1,
    name: "Alchemy",
    ws_url: "wss://eth-mainnet.g.alchemy.com/v2/#{YOUR_KEY_HERE}",
    url: "https://eth-mainnet.alchemyapi.io/v2/#{YOUR_KEY_HERE}"
  ],
  [
    chain_id: 8453,
    name: "Alchemy",
    ws_url: "wss://base-mainnet.g.alchemy.com/v2/#{YOUR_KEY_HERE}",
    url: "https://base-mainnet.g.alchemy.com/v2/#{YOUR_KEY_HERE}"
  ],
  [
    chain_id: 137,
    name: "Alchemy",
    url: "https://polygon-mainnet.g.alchemy.com/v2/#{YOUR_KEY_HERE}",
    ws_url: "wss://polygon-mainnet.g.alchemy.com/v2/#{YOUR_KEY_HERE}"
  ],
  [
    chain_id: 42161,
    name: "Alchemy",
    url: "https://arb-mainnet.g.alchemy.com/v2/#{YOUR_KEY_HERE}",
    ws_url: "wss://arb-mainnet.g.alchemy.com/v2/#{YOUR_KEY_HERE}"
  ],
  [
    chain_id: 10,
    name: "Alchemy",
    url: "https://opt-mainnet.g.alchemy.com/v2/#{YOUR_KEY_HERE}",
    ws_url: "wss://opt-mainnet.g.alchemy.com/v2/#{YOUR_KEY_HERE}"
  ],
  [
    chain_id: 250,
    name: "Fantom",
    ws_url: "wss://wsapi.fantom.network/",
    url: "https://xapi.fantom.network"
  ]
]

dexes = [
  [
    chain_id: 250,
    name: "Spookyswap",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/eerieeight/spookyswap"
  ],
  [
    chain_id: 43114,
    name: "TraderJoe",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/traderjoe-xyz/exchange"
  ],
  [
    chain_id: 1,
    name: "Pancake",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/pancakeswap/exhange-eth"
  ],
  [
    chain_id: 1,
    name: "Pancake",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/pancakeswap/exchange-v3-eth"
  ],
  [
    chain_id: 1,
    name: "Sushiswap",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v2/sushiswap-ethereum"
  ],
  [
    chain_id: 1,
    name: "Sushiswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v3/v3-ethereum"
  ],
  [
    chain_id: 1,
    name: "Uniswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3"
  ],
  [
    chain_id: 1,
    name: "Uniswap",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/ianlapham/uniswapv2"
  ],
  [
    chain_id: 137, # Polygon
    name: "Uniswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/ianlapham/uniswap-v3-polygon"
  ],
  [
    chain_id: 137, # Polygon
    name: "Sushiswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v3/v3-polygon"
  ],
  [
    chain_id: 137, # Polygon
    name: "Sushiswap",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v2/sushiswap-polygon"
  ],
  [
    chain_id: 42161, #Arbitrum
    name: "Pancake",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/pancakeswap/exchange-v3-arb"
  ],
  [
    chain_id: 42161,
    name: "Uniswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/ianlapham/uniswap-arbitrum-one"
  ],
  [
    chain_id: 42161,
    name: "Pancake",
    type: "v2",
    gql_url: "https://api.studio.thegraph.com/query/45376/exchange-v2-arbitrum/version/latest"
  ],
  [
    chain_id: 42161,
    name: "Sushiswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v3/v3-arbitrum"
  ],
  [
    chain_id: 10,
    name: "Uniswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/ianlapham/optimism-post-regenesis"
  ],
  [
    chain_id: 10,
    name: "Sushiswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v3/v3-optimism"
  ],
  [
    chain_id: 10,
    name: "Sushiswap",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v2/sushiswap-optimism"
  ],
  [
    chain_id: 250,
    name: "Spookyswap",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/eerieeight/spookyswap"
  ],
  [
    chain_id: 250,
    name: "Sushiswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v3/v3-fantom"
  ],
  [
    chain_id: 250,
    name: "Sushiswap",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v2/sushiswap-fantom"
  ],
  [
    chain_id: 56,
    name: "Pancake",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/pancakeswap/exhange-bsc"
  ],
  [
    chain_id: 56,
    name: "Pancake",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/pancakeswap/exchange-v3-bnb"
  ],
  [
    chain_id: 56,
    name: "Sushiswap",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v2/sushiswap-bsc"
  ],
  [
    chain_id: 56,
    name: "Sushiswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v3/v3-bsc"
  ],
  [
    chain_id: 56,
    name: "Uniswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/ianlapham/uniswap-v3-bsc"
  ],
  [
    chain_id: 43114,
    name: "Uniswap",
    type: "v3",
    gql_url: "https://api.thegraph.com/subgraphs/name/lynnshaoyu/uniswap-v3-avax"
  ],
  [
    chain_id: 43114,
    name: "Sushiswap",
    type: "v2",
    gql_url: "https://api.thegraph.com/subgraphs/name/sushi-v2/sushiswap-avalanche"
  ],
  [
    chain_id: 8453,
    name: "Uniswap",
    type: "v3",
    gql_url: "https://api.studio.thegraph.com/query/48211/uniswap-v3-base/version/latest"
  ],
  [
    chain_id: 8453,
    name: "Pancake",
    type: "v3",
    gql_url: "https://api.studio.thegraph.com/query/45376/exchange-v3-base/version/latest"
  ],
  [
    chain_id: 8453,
    name: "Pancake",
    type: "v2",
    gql_url: "https://api.studio.thegraph.com/query/45376/exchange-v2-base/version/latest"
  ],
  [
    chain_id: 8453,
    name: "Sushiswap",
    type: "v3",
    gql_url: "https://api.studio.thegraph.com/query/32073/v3-base/v0.0.1"
  ],
  [
    chain_id: 8453,
    name: "Sushiswap",
    type: "v2",
    gql_url: "https://api.studio.thegraph.com/query/32073/sushiswap-base/v0.0.1"
  ]
]

tokens = [
  [
    name: "Ethereum",
    symbol: "ETH",
    decimals: 18,
    chain_id: 1,
    address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    block_deployed: nil
  ],
  [
    name: "Ethereum",
    symbol: "ETH",
    decimals: 18,
    chain_id: 250,
    address: "0x695921034f0387eac4e11620ee91b1b15a6a09fe",
    block_deployed: nil
  ],
  [
    name: "Ethereum",
    symbol: "ETH",
    decimals: 18,
    chain_id: 10,
    address: "0x4200000000000000000000000000000000000006",
    block_deployed: nil
  ],
  [
    name: "Ethereum",
    symbol: "ETH",
    decimals: 18,
    chain_id: 42161,
    address: "0x82af49447d8a07e3bd95bd0d56f35241523fbab1",
    block_deployed: nil
  ],
  [
    name: "Ethereum",
    symbol: "ETH",
    decimals: 18,
    chain_id: 137,
    address: "0x7ceb23fd6bc0add59e62ac25578270cff1b9f619",
    block_deployed: nil
  ],
  [
    name: "Ethereum",
    symbol: "ETH",
    decimals: 18,
    chain_id: 43114,
    address: "0x49d5c2bdffac6ce2bfdb6640f4f80f226bc10bab",
    block_deployed: nil
  ],
  [
    name: "USDC",
    symbol: "USDC",
    decimals: 6,
    chain_id: 1,
    address: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    block_deployed: nil
  ],
  [
    name: "USDC",
    symbol: "USDC",
    decimals: 6,
    chain_id: 250,
    address: "0x28a92dde19d9989f39a49905d7c9c2fac7799bdf",
    block_deployed: nil
  ],
  [
    name: "USDC",
    symbol: "USDC",
    decimals: 6,
    chain_id: 10,
    address: "0x7f5c764cbc14f9669b88837ca1490cca17c31607",
    block_deployed: nil
  ],
  [
    name: "USDC",
    symbol: "USDC",
    decimals: 6,
    chain_id: 42161,
    address: "0xff970a61a04b1ca14834a43f5de4533ebddb5cc8",
    block_deployed: nil
  ],
  [
    name: "USDC",
    symbol: "USDC",
    decimals: 6,
    chain_id: 137,
    address: "0x2791bca1f2de4661ed88a30c99a7a9449aa84174",
    block_deployed: nil
  ],
  [
    name: "USDC",
    symbol: "USDC",
    decimals: 6,
    chain_id: 43114,
    address: "0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e",
    block_deployed: nil
  ],
  [
    name: "StargateToken",
    symbol: "STG",
    decimals: 18,
    chain_id: 1,
    address: "0xaf5191b0de278c7286d6c7cc6ab6bb8a73ba2cd6",
    block_deployed: nil
  ],
  [
    name: "StargateToken",
    symbol: "STG",
    decimals: 18,
    chain_id: 250,
    address: "0x2f6f07cdcf3588944bf4c42ac74ff24bf56e7590",
    block_deployed: nil
  ],
  [
    name: "StargateToken",
    symbol: "STG",
    decimals: 18,
    chain_id: 10,
    address: "0x296f55f8fb28e498b858d0bcda06d955b2cb3f97",
    block_deployed: nil
  ],
  [
    name: "StargateToken",
    symbol: "STG",
    decimals: 18,
    chain_id: 42161,
    address: "0x6694340fc020c5e6b96567843da2df01b2ce1eb6",
    block_deployed: nil
  ],
  [
    name: "StargateToken",
    symbol: "STG",
    decimals: 18,
    chain_id: 137,
    address: "0x2f6f07cdcf3588944bf4c42ac74ff24bf56e7590",
    block_deployed: nil
  ],
  [
    name: "StargateToken",
    symbol: "STG",
    decimals: 18,
    chain_id: 43114,
    address: "0x2f6f07cdcf3588944bf4c42ac74ff24bf56e7590",
    block_deployed: nil
  ],
  [
    name: "StargateToken",
    symbol: "STG",
    decimals: 18,
    chain_id: 56,
    address: "0xb0d502e938ed5f4df2e681fe6e419ff29631d62b",
    block_deployed: nil
  ]
]

pairs = [
  [
    addres: "0xaa5255e83a4322ef4926b2c76d77ab8b94a5c0f2",
    name: "STG_USDC_V2_250_Spookyswap",
    symbol: "STG_USDC",
    dex_id: 17,
    chain_id: 250,
    token0: "0x28a92dde19d9989f39a49905d7c9c2fac7799bdf",
    token1: "0x2f6f07cdcf3588944bf4c42ac74ff24bf56e7590"
  ],
  [
    addres: "0xa34ec05da1e4287fa351c74469189345990a3f0c",
    name: "STG_USDC_V2_137_Sushiswap",
    symbol: "STG_USDC",
    dex_id: 9,
    chain_id: 137,
    token0: "0x2791bca1f2de4661ed88a30c99a7a9449aa84174",
    token1: "0x2f6f07cdcf3588944bf4c42ac74ff24bf56e7590"
  ],
  [
    addres: "0x330f77bda60d8dab14d2bb4f6248251443722009",
    name: "STG_USDC_V2_43114_TraderJoe",
    symbol: "STG_USDC",
    dex_id: 32,
    chain_id: 43114,
    token0: "0x2f6f07cdcf3588944bf4c42ac74ff24bf56e7590",
    token1: "0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e"
  ],
  [
    addres: "0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc",
    name: "WETH_USDC_V2_1_Uniswap",
    symbol: "WETH_USDC",
    dex_id: 6,
    chain_id: 1,
    token0: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    token1: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
  ],
  [
    addres: "0x397ff1542f962076d0bfe58ea045ffa2d347aca0",
    name: "WETH_USDC_V2_1_Sushiswap",
    symbol: "WETH_USDC",
    dex_id: 3,
    chain_id: 1,
    token0: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    token1: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
  ]
]

pools = [
  [
    addres: "0x6ce6d6d40a4c4088309293b0582372a2e6bb632e",
    name:	"STG_WETH_3000_1_Uniswap",
    symbol:	"STG_WETH",
    dex_id:	5,
    chain_id:	1,
    fee: 3000,
    tick_spacing:	60,
    token0:	"0xaf5191b0de278c7286d6c7cc6ab6bb8a73ba2cd6",
    token1: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    block_deployed: 14414580
  ],
  [
    addres: "0x0ca747e5c527e857d8a71b53b6efbad2866b9e04",
    name: "STG_WETH_3000_10_Uniswap",
    symbol: "STG_WETH",
    dex_id:	14,
    chain_id:	10,
    fee: 3000,
    tick_spacing:	60,
    token0:	"0x296f55f8fb28e498b858d0bcda06d955b2cb3f97",
    token1: "0x4200000000000000000000000000000000000006",
    block_deployed: 43549342
  ],
  [
    addres: "0xa8bd646f72ea828ccbc40fa2976866884f883409",
    name: "STG_WETH_3000_42161_Uniswap",
    symbol: "STG_WETH",
    dex_id:	11,
    chain_id:	42161,
    fee: 3000,
    tick_spacing:	60,
    token0:	"0x6694340fc020c5e6b96567843da2df01b2ce1eb6",
    token1: "0x82af49447d8a07e3bd95bd0d56f35241523fbab1",
    block_deployed: 22887242
  ],
  [
    addres: "0x001913e47344803b29e36df81ad267a2739e55cd",
    name: "STG_WETH_500_42161_Uniswap",
    symbol: "STG_WETH",
    dex_id:	11,
    chain_id:	42161,
    fee: 500,
    tick_spacing:	10,
    token0:	"0x6694340fc020c5e6b96567843da2df01b2ce1eb6",
    token1: "0x82af49447d8a07e3bd95bd0d56f35241523fbab1",
    block_deployed: 27544530
  ],
  [
    addres: "0x7524fe020edcd072ee98126b49fa65eb85f8c44c",
    name: "STG_USDC_2500_1_Pancake",
    symbol: "USDC_STG",
    dex_id:	2,
    chain_id:	1,
    fee: 2500,
    tick_spacing:	50,
    token0:	"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    token1: "0xaf5191b0de278c7286d6c7cc6ab6bb8a73ba2cd6",
    block_deployed: 16968469
  ],
  [
    addres: "0x8592064903ef23d34e4d5aaaed40abf6d96af186",
    name: "STG_USDC_10000_1_Uniswap",
    symbol: "USDC_STG",
    dex_id:	5,
    chain_id:	1,
    fee: 10000,
    tick_spacing:	200,
    token0:	"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    token1: "0xaf5191b0de278c7286d6c7cc6ab6bb8a73ba2cd6",
    block_deployed: 14410328
  ],
  [
    addres: "0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8",
    name: "WETH_USDC_3000_1_Uniswap",
    symbol: "USDC_WETH",
    dex_id:	5,
    chain_id:	1,
    fee: 3000,
    tick_spacing:	60,
    token0:	"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    token1: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    block_deployed: 12370624
  ],
  [
    addres: "0x1ac1a8feaaea1900c4166deeed0c11cc10669d36",
    name: "WETH_USDC_500_1_Pancake",
    symbol: "USDC_WETH",
    dex_id:	2,
    chain_id:	1,
    fee: 500,
    tick_spacing:	10,
    token0:	"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    token1: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    block_deployed: 16954933
  ],
  [
    addres: "0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640",
    name: "WETH_USDC_500_1_Uniswap",
    symbol: "USDC_WETH",
    dex_id:	5,
    chain_id:	1,
    fee: 500,
    tick_spacing:	10,
    token0:	"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    token1: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    block_deployed: 12376729
  ],
  [
    addres: "0x85149247691df622eaf1a8bd0cafd40bc45154a9",
    name: "WETH_USDC_500_10_Uniswap",
    symbol: "WETH_USDC",
    dex_id:	14,
    chain_id:	10,
    fee: 500,
    tick_spacing:	10,
    token0:	"0x4200000000000000000000000000000000000006",
    token1: "0x7f5c764cbc14f9669b88837ca1490cca17c31607",
    block_deployed: 191
  ],
  [
    addres: "0xc6962004f452be9203591991d15f6b388e09e8d0",
    name: "WETH_USDC_500_42161_Uniswap",
    symbol: "WETH_USDC",
    dex_id:	11,
    chain_id:	42161,
    fee: 500,
    tick_spacing:	10,
    token0:	"0x82af49447d8a07e3bd95bd0d56f35241523fbab1",
    token1: "0xaf88d065e77c8cc2239327c5edb3a432268e5831",
    block_deployed: 99174111
  ],
  [
    addres: "0x45dda9cb7c25131df268515131f647d726f50608",
    name: "WETH_USDC_500_137_Uniswap",
    symbol: "USDC_WETH",
    dex_id:	7,
    chain_id:	137,
    fee: 500,
    tick_spacing:	10,
    token0:	"0x2791bca1f2de4661ed88a30c99a7a9449aa84174",
    token1: "0x7ceb23fd6bc0add59e62ac25578270cff1b9f619",
    block_deployed: 22765962
  ]
]

Arbitron.Repo.insert_all("chains", chains)
Arbitron.Repo.insert_all("providers", providers)
Arbitron.Repo.insert_all("dexes", dexes)
Arbitron.Repo.insert_all("tokens", tokens)
Arbitron.Repo.insert_all("pairs", pairs)
Arbitron.Repo.insert_all("pools", pools)
