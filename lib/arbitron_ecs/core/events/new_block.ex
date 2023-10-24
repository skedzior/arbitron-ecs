defmodule NewBlock do
  use TypedStruct

  typedstruct do
    field :number, non_neg_integer(), enforce: true
    field :hash, String.t()
    field :timestamp, non_neg_integer()
  end
end
