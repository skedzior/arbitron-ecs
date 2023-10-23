defmodule Pool do
  use TypedStruct

  @topics %{
    mint: "0x7a53080ba414158be7ec69b987b5fb7d07dee101fe85488f0853ae16239d0bde",
    burn: "0x0c396cd989a39f4459b5fa1aed6a9a8dcdbc45908acfd67e028cd568da98982c",
    swap: "0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67"
  }

  typedstruct do
    field :address, String.t(), enforce: true
    field :name, String.t()
    field :symbol, String.t()
    field :dex, String.t() # dex()
    field :fee, non_neg_integer()
    field :tick_spacing, non_neg_integer()
    field :topics, Map.t(), default: @topics
  end

  def new(info) do
    pool = struct(Pool, info)

    pool
    |> EntityDefinition.new()
    |> ECS.Entity.build()
    |> ECS.Entity.add(Mint.new(%{}))
    |> ECS.Entity.add(Burn.new(%{}))
    |> ECS.Entity.add(Swap.new(%{}))

    pool
  end

  def topics, do: @topics
end
