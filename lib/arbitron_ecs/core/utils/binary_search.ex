# defmodule Arbitron.Utils.BinarySearch do
#   alias Arbitron.Contracts.{Pool, Pair}
#   alias Arbitron.Structs.{Swap, MultiSwap}
#   alias Arbitron.Uniswap.{V2, V3}

#   def search_v2(pair, am_in, out_min, min, max, last \\ nil) do
#     mid = trunc(div(min + max, 2))

#     {fr_out, fr_pair} = Swap.get_amount_out(pair, mid, false)
#     {vic_out, vic_pair} = Swap.get_amount_out(fr_pair, am_in, false)
#     {br_out, br_pair} = Swap.get_amount_out(vic_pair, fr_out, true)

#     cond do
#       last == mid -> mid
#       vic_out < out_min -> search_v2(pair, am_in, out_min, min, mid - 1, mid)
#       vic_out > out_min -> search_v2(pair, am_in, out_min, mid + 1, max, mid)
#       vic_out == out_min -> mid
#     end
#   end

#   def search_v2(pair, %Swap{amount_in: am_in, amount_min_max: out_min} = vic_swap, min, max),
#     do: search_v2(pair, am_in, out_min, min, max)

#   def search_v2(
#         %Pair{reserve0: r0, reserve1: r1, fee: fee} = pair,
#         %Swap{amount_in: am_in, amount_min_max: out_min, zero_for_one: zero_for_one} = vic_swap
#       ) do
#     %{new_r0: _r0, new_r1: _r1, sando_in: fr_in} =
#       V2.calculate_optimal_sando(am_in, out_min, r0, r1, zero_for_one, fee)

#     search_v2(pair, vic_swap, fr_in, fr_in + 700_000_000_000_000)
#   end

#   def search_v3(init_sqrtp, pool_fee, ts, vic_in, out_min, min, max, last, summary) do
#     mid = trunc(div(min + max, 2))

#     {fr_nextp, fr_am_in, fr_am_out} = V3.exact_in_swap(ts, pool_fee, init_sqrtp, mid, 0, false)
#     IO.inspect({fr_nextp, fr_am_in, fr_am_out})

#     {nextp, vic_am_in, vic_out} = V3.exact_in_swap(ts, pool_fee, fr_nextp, vic_in, 0, false)
#     IO.inspect({nextp, vic_am_in, vic_out})

#     {nextpp, br_am_in, br_am_out} = V3.exact_in_swap(ts, pool_fee, nextp, fr_am_out, 0, true)
#     IO.inspect({nextpp, br_am_in, br_am_out})

#     profit = br_am_out - fr_am_in
#     # IO.inspect({fr_out, vic_out}, label: "result")
#     IO.inspect({mid, profit}, label: "profit")
#     summary = Enum.concat(summary, [[profit, mid, vic_out >= out_min]])

#     cond do
#       last == mid ->
#         summary

#       vic_out < out_min ->
#         search_v3(init_sqrtp, pool_fee, ts, vic_in, out_min, min, mid - 1, mid, summary)

#       vic_out > out_min ->
#         search_v3(init_sqrtp, pool_fee, ts, vic_in, out_min, mid + 1, max, mid, summary)

#       vic_out == out_min ->
#         summary
#     end
#   end

#   def search_v3_exhaustive(
#         %Pool{tick_state: tick_state, sqrtp_x96: init_sqrtp, tick_spacing: tick_spacing} = pool,
#         %Swap{zero_for_one: zero_for_one} = fr_swap,
#         %Swap{amount_in: vic_in, amount_min_max: out_min} = vic_swap
#       ) do
#     lower_bound_tick = V3.sqrt_ratio_to_tick(init_sqrtp)
#     avg_worst_price = vic_in / out_min
#     avg_worst_tick = V3.price_to_tick(avg_worst_price)

#     [_lower_tick, upper_bound_tick] =
#       V3.get_current_tick_range(avg_worst_tick, tick_spacing, zero_for_one)

#     tick_state_d = V3.get_directional_tick_state(tick_state, init_sqrtp, zero_for_one)
#         IO.inspect({upper_bound_tick, lower_bound_tick}, label: "upper_bound_tick lower_bound_tick")
#     upper_bound_tick..lower_bound_tick
#     |> Enum.reduce({0, []}, fn t, {tick_state_idx, summary} ->
#       [tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)

#       {tick_state_idx, current_liq} =
#         if t < tick_pntr do
#           {tick_state_idx, liq_pntr}
#         else
#           tick_state_idx = tick_state_idx + 1
#           [_tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)
#           {tick_state_idx, liq_pntr}
#         end

#       target_sqrtp = V3.tick_to_sqrt_ratio(t)

#       fr_in =
#         if zero_for_one,
#           do: V3.get_amount0_delta(init_sqrtp, target_sqrtp, current_liq, true),
#           else: V3.get_amount1_delta(init_sqrtp, target_sqrtp, current_liq, true)

#       {fr_pool, fr_am_out} = Swap.do_swap(pool, %Swap{fr_swap | amount_in: fr_in})

#       {vic_pool, vic_out} = Swap.do_swap(fr_pool, vic_swap)

#       if vic_out >= vic_swap.amount_min_max do
#         {br_pool, br_am_out} = Swap.do_swap(vic_pool, fr_am_out, !zero_for_one)
#         profit = br_am_out - fr_in
#         {tick_state_idx, [[profit, fr_in, t, target_sqrtp] | summary]}
#       else
#         {tick_state_idx, summary}
#       end
#     end)
#     |> elem(1)
#   end

#   def search_v3(
#         %Pool{} = pool,
#         %Swap{zero_for_one: zero_for_one} = fr_swap,
#         %Swap{amount_min_max: out_min} = vic_swap,
#         min,
#         max,
#         last,
#         summary
#       ) do
#     mid =
#       D.div(min + max, 2)
#       |> D.round(0, :floor)
#       |> D.to_integer()

#     IO.inspect(mid)
#     {fr_pool, fr_am_out} = Swap.do_swap(pool, %Swap{fr_swap | amount_in: mid})

#     {vic_pool, vic_out} = Swap.do_swap(fr_pool, vic_swap)

#     {br_pool, br_am_out} = Swap.do_swap(vic_pool, fr_am_out, !zero_for_one)

#     profit = br_am_out - mid
#     summary = Enum.concat(summary, [[profit, mid]])

#     cond do
#       last == mid ->
#         summary

#       vic_out < out_min ->
#         search_v3(pool, fr_swap, vic_swap, min, mid - 1, mid, summary)

#       vic_out > out_min && profit > 0 ->
#         search_v3(pool, fr_swap, vic_swap, mid + 1, max, mid, summary)

#       vic_out == out_min ->
#         summary
#     end
#   end

#   def search_v3_jit_non_compute(
#         %Pool{sqrtp_x96: sqrtp_x96, tick_state: tick_state, tick_spacing: tick_spacing} = pool,
#         %Swap{zero_for_one: zero_for_one} = fr_swap,
#         %Swap{amount_in: amount_in, amount_min_max: out_min} = vic_swap,
#         amount1_mint_limit \\ 0
#       ) do
#     # {vic_pool_no_fr, vic_out_no_fr} = Swap.do_swap(pool, vic_swap)
#     # lower_bound_sqrtp = vic_pool_no_fr.sqrtp_x96
#     # lower_bound_tick = V3.sqrt_ratio_to_tick(lower_bound_sqrtp)
#     lower_bound_tick = V3.sqrt_ratio_to_tick(pool.sqrtp_x96)
#     avg_worst_price = amount_in / out_min
#     avg_worst_tick = V3.price_to_tick(avg_worst_price)

#     [_lower_tick, upper_bound_tick] =
#       V3.get_current_tick_range(avg_worst_tick, tick_spacing, fr_swap.zero_for_one)

#     tick_state_d = V3.get_directional_tick_state(tick_state, sqrtp_x96, zero_for_one)

#     upper_bound_tick..lower_bound_tick
#     |> Enum.reduce({0, 0, []}, fn t, {tick_state_idx, profit_pntr, summary} ->
#       [tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)

#       {tick_state_idx, current_liq} =
#         if t < tick_pntr do
#           {tick_state_idx, liq_pntr}
#         else
#           tick_state_idx = tick_state_idx + 1
#           [_tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)
#           {tick_state_idx, liq_pntr}
#         end

#       target_sqrtp = V3.tick_to_sqrt_ratio(t)

#       fr_in =
#         if zero_for_one,
#           do: V3.get_amount0_delta(sqrtp_x96, target_sqrtp, current_liq, false),
#           else: V3.get_amount1_delta(sqrtp_x96, target_sqrtp, current_liq, true)

#       # TODO: use this if to set other params like fee token

#       {fr_pool, fr_out} = Swap.do_swap(pool, %Swap{fr_swap | amount_in: fr_in})

#       # Swap.compute_jit_swap_ranges(fr_pool, vic_swap, fr_in, fr_out, amount1_mint_limit, summary)
#       fr_tick = V3.sqrt_ratio_to_tick(fr_pool.sqrtp_x96)

#       [lower_tick, upper_tick] =
#         if amount1_mint_limit == 0 do
#           V3.get_next_tick_range(fr_tick, tick_spacing, fr_swap.zero_for_one)
#         else
#           V3.get_current_tick_range(fr_tick, tick_spacing, fr_swap.zero_for_one)
#         end

#       %{
#         amount_out: vic_out,
#         amount0_burned: to_sell,
#         next_sqrtp: jit_sqrtp,
#         amount1_burned: amount1_burned,
#         jit_fees: jit_fees,
#         pool: jit_pool,
#         amount0_minted: amount0_minted,
#         amount1_minted: amount1_minted
#       } =
#         jit_resp =
#         Swap.jit_swap(
#           fr_pool,
#           vic_swap,
#           fr_out,
#           amount1_mint_limit,
#           lower_tick,
#           upper_tick
#         )

#       jit_tick = V3.sqrt_ratio_to_tick(jit_pool.sqrtp_x96)

#       if vic_out >= vic_swap.amount_min_max do
#         {br_pool, br_out} =
#           if to_sell > 0,
#             do: Swap.do_swap(jit_pool, to_sell, !fr_swap.zero_for_one),
#             else: {jit_pool, 0}

#         profit = br_out + amount1_burned + jit_fees - fr_in - amount1_minted

#         if profit >= profit_pntr do
#           br_tick = V3.sqrt_ratio_to_tick(br_pool.sqrtp_x96)

#           {tick_state_idx, profit,
#            [
#              [
#                profit,
#                fr_in,
#                lower_tick,
#                upper_tick,
#                amount0_minted,
#                amount1_minted,
#                # ,jit_resp}
#                {fr_tick, fr_pool.sqrtp_x96, jit_tick, jit_sqrtp, br_tick, br_pool.sqrtp_x96}
#              ]
#              | summary
#            ]}
#         else
#           {tick_state_idx, profit_pntr, summary}
#         end
#       else
#         {tick_state_idx, profit_pntr, summary}
#       end
#     end)
#     |> elem(2)
#   end

#   def search_v3_jit_all(
#         %Pool{sqrtp_x96: sqrtp_x96, tick_state: tick_state, tick_spacing: tick_spacing} = pool,
#         %Swap{zero_for_one: zero_for_one} = fr_swap,
#         %Swap{amount_in: amount_in, amount_min_max: out_min} = vic_swap,
#         amount1_mint_limit,
#         lower_bound_tick,
#         upper_bound_tick,
#         added_amount0
#       ) do
#     tick_state_d = V3.get_directional_tick_state(tick_state, sqrtp_x96, zero_for_one)

#     upper_bound_tick..lower_bound_tick
#     |> Enum.reduce({0, []}, fn t, {tick_state_idx, summary} ->
#       [tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)

#       {tick_state_idx, current_liq} =
#         if t < tick_pntr do
#           {tick_state_idx, liq_pntr}
#         else
#           tick_state_idx = tick_state_idx + 1
#           [_tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)
#           {tick_state_idx, liq_pntr}
#         end

#       target_sqrtp = V3.tick_to_sqrt_ratio(t)

#       fr_in =
#         if zero_for_one,
#           do: V3.get_amount0_delta(sqrtp_x96, target_sqrtp, current_liq, false),
#           else: V3.get_amount1_delta(sqrtp_x96, target_sqrtp, current_liq, true)

#       # TODO: use this if to set other params like fee token
#       {fr_pool, fr_out} = Swap.do_swap(pool, %Swap{fr_swap | amount_in: fr_in})

#       {tick_range, compute_summary, _profit} =
#         Swap.compute_jit_swap_ranges_all(
#           fr_pool,
#           vic_swap,
#           fr_in,
#           fr_out + added_amount0,
#           amount1_mint_limit
#         )

#       {tick_state_idx, Enum.concat(compute_summary, summary)}
#     end)
#     |> elem(1)
#   end

#   def search_v3_jit(
#         %Pool{sqrtp_x96: sqrtp_x96, tick_state: tick_state, tick_spacing: tick_spacing} = pool,
#         %Swap{zero_for_one: zero_for_one} = fr_swap,
#         %Swap{amount_in: amount_in, amount_min_max: out_min} = vic_swap,
#         amount1_mint_limit,
#         lower_bound_tick,
#         upper_bound_tick,
#         added_amount0
#       ) do
#     tick_state_d = V3.get_directional_tick_state(tick_state, sqrtp_x96, zero_for_one)

#     upper_bound_tick..lower_bound_tick
#     |> Enum.reduce({0, []}, fn t, {tick_state_idx, summary} ->
#       [tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)

#       {tick_state_idx, current_liq} =
#         if t < tick_pntr do
#           {tick_state_idx, liq_pntr}
#         else
#           tick_state_idx = tick_state_idx + 1
#           [_tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)
#           {tick_state_idx, liq_pntr}
#         end

#       target_sqrtp = V3.tick_to_sqrt_ratio(t)

#       fr_in =
#         if zero_for_one,
#           do: V3.get_amount0_delta(sqrtp_x96, target_sqrtp, current_liq, false),
#           else: V3.get_amount1_delta(sqrtp_x96, target_sqrtp, current_liq, true)

#       # TODO: use this if to set other params like fee token
#       {fr_pool, fr_out} = Swap.do_swap(pool, %Swap{fr_swap | amount_in: fr_in})

#       {tick_range, compute_summary, _profit} =
#         Swap.compute_jit_swap_ranges(
#           fr_pool,
#           vic_swap,
#           fr_in,
#           fr_out + added_amount0,
#           amount1_mint_limit
#         )

#       {tick_state_idx, Enum.concat(compute_summary, summary)}
#     end)
#     |> elem(1)
#   end

#   # override search bounds
#   def search_v3_jit(
#         %Pool{sqrtp_x96: sqrtp_x96, tick_state: tick_state, tick_spacing: tick_spacing} = pool,
#         %Swap{zero_for_one: zero_for_one} = fr_swap,
#         %Swap{amount_in: amount_in, amount_min_max: out_min} = vic_swap,
#         amount1_mint_limit,
#         lower_bound_tick,
#         upper_bound_tick
#       ) do
#     tick_state_d = V3.get_directional_tick_state(tick_state, sqrtp_x96, zero_for_one)

#     upper_bound_tick..lower_bound_tick
#     |> Enum.reduce({0, []}, fn t, {tick_state_idx, summary} ->
#       [tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)

#       {tick_state_idx, current_liq} =
#         if t < tick_pntr do
#           {tick_state_idx, liq_pntr}
#         else
#           tick_state_idx = tick_state_idx + 1
#           [_tick_pntr, liq_pntr] = Enum.at(tick_state_d, tick_state_idx)
#           {tick_state_idx, liq_pntr}
#         end

#       target_sqrtp = V3.tick_to_sqrt_ratio(t)

#       fr_in =
#         if zero_for_one,
#           do: V3.get_amount0_delta(sqrtp_x96, target_sqrtp, current_liq, false),
#           else: V3.get_amount1_delta(sqrtp_x96, target_sqrtp, current_liq, true)

#       # TODO: use this if to set other params like fee token
#       {fr_pool, fr_out} = Swap.do_swap(pool, %Swap{fr_swap | amount_in: fr_in})

#       {tick_range, compute_summary, _profit} =
#         Swap.compute_jit_swap_ranges(fr_pool, vic_swap, fr_in, fr_out, amount1_mint_limit)

#       {tick_state_idx, Enum.concat(compute_summary, summary)}
#     end)
#     |> elem(1)
#   end

#   def search_v3_jit(
#         %Pool{sqrtp_x96: sqrtp_x96, tick_state: tick_state, tick_spacing: tick_spacing} = pool,
#         %Swap{zero_for_one: zero_for_one} = fr_swap,
#         %Swap{amount_in: amount_in, amount_min_max: out_min} = vic_swap,
#         amount1_mint_limit,
#         lower_bound_tick
#       ) do
#     avg_worst_price = amount_in / out_min
#     avg_worst_tick = V3.price_to_tick(avg_worst_price)

#     [_lower_tick, upper_bound_tick] =
#       V3.get_current_tick_range(avg_worst_tick, tick_spacing, fr_swap.zero_for_one)

#     search_v3_jit(pool, fr_swap, vic_swap, amount1_mint_limit, lower_bound_tick, upper_bound_tick)
#   end

#   def search_v3_jit(
#         %Pool{sqrtp_x96: sqrtp_x96, tick_state: tick_state, tick_spacing: tick_spacing} = pool,
#         %Swap{zero_for_one: zero_for_one} = fr_swap,
#         %Swap{amount_in: amount_in, amount_min_max: out_min} = vic_swap,
#         amount1_mint_limit
#       ) do
#     lower_bound_tick = V3.sqrt_ratio_to_tick(pool.sqrtp_x96)
#     avg_worst_price = amount_in / out_min
#     avg_worst_tick = V3.price_to_tick(avg_worst_price)

#     [_lower_tick, upper_bound_tick] =
#       V3.get_current_tick_range(avg_worst_tick, tick_spacing, fr_swap.zero_for_one)

#     search_v3_jit(pool, fr_swap, vic_swap, amount1_mint_limit, lower_bound_tick, upper_bound_tick)
#   end
# end
