# Arbitron

## Description

Arbitron is an Elixir library that provides utilities for monitoring and processing blockchain events. The modules cover a wide range of functionalities - with the integration of GenStage and Broadway, it offers real-time event subscriptions and focuses on event streaming, processing, and decoding of smart-contract event logs.

## Key Modules

1. `Arbitron.Manager`: Uses a `DynamicSupervisor` to start workers dynamically. The `autostart` functions here are responsible for creating processes that start streaming data for chains, pairs, and pools.

2. `Arbitron.Streamer.Worker`: This is the worker module that handles connecting to a WebSocket endpoint, streaming data from it, and then broadcasting that data to listeners.

3. `Arbitron.Producer`: Uses GenStage to define a producer for Broadway. This producer interacts with the Phoenix PubSub system to receive and process blockchain events.
4. `Arbitron.Pipeline`: Implements a Broadway pipeline for consuming and processing blockchain event messages.

5. **ECS**: Entity-Component-System architecture is typically used in game development but can be adapted for other systems that need to manage and process a large number of entities with different attributes and behaviors.
   - `ECS.Service`: Service behaviors for processing and dispatching actions.
   - `ECS.Entity`: Entity behaviors including methods to build, update, and manage state for entities.
   - `ECS.Entity.Agent`: This is a simple agent wrapper for state management.

6. **Services**: `ChainService`, `PairService`, and `PoolService` are specific implementations that handle events related to chains, pairs, and pools respectively. They are responsible for processing events and updating the state of the respective entities.

7. Entities: The following modules define typed structs that represent different blockchain entities:
- `Chain`: Represents a blockchain chain.
- `Pool`: Represents a liquidity pool.
- `Pair`: Represents a token pair.
- `Dex`: Represents a decentralized exchange.
- `Sync`, `Swap`, `PendingTx`, `NewBlock`, `Mint`, `Burn`, and `EventLog`: Represent various blockchain-related smart contract events.
   
## Usage

### Creating Entities

To create a new Chain entity:
```elixir
chain_data = %{
  id: 1,
  name: "Ethereum",
  symbol: "ETH"
}
Chain.new(chain_data)
```

To create a new Pool entity:
```elixir
pool_data = %{
  address: "0x...",
  name: "Pool1",
  symbol: "P1",
  dex: "Uniswap",
  fee: 0.03,
  tick_spacing: 60
}
Pool.new(pool_data)
```

