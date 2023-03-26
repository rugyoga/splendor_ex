defmodule Splendor.Hand do
    @moduledoc """
    Represents a Splendor hand
    """
    alias Splendor.{Card, Hand, T}

    defstruct points: 0,
        chips: %{black: 0, blue: 0, gold: 0, green: 0, red: 0, white: 0, count: 0},
        bought: [],
        reserved: []

    @type t :: %__MODULE__{
        points: integer(),
        chips: T.chips_with_count(),
        bought: T.cards(),
        reserved: T.cards()
    }

    @spec reserve(t(), Card.t()) :: t()
    def reserve(hand, card) do
        %Hand{hand |
            reserved: [card | hand.reserved],
            chips: hand.chips |> change(:gold)
        }
    end

    @spec buy(t(), Card.t()) :: t()
    def buy(hand, card) do
        %Hand{hand |
            points: hand.points + card.points,
            chips: update(hand.chips, card.required, &Kernel.-/2),
            bought: [card | hand.bought]
        }
    end

    @spec grab(t(), T.chips()) :: t()
    def grab(hand, chips), do: %Hand{hand | chips: update(hand.chips, chips)}

    @doc """
    Change the chips by delta (inc count)

    ## Examples

        iex> Hand.update(%{blue: 0, count: 0}, %{blue: 1})
        %{blue: 1, count: 1}
    """
    @spec update(T.chips_with_count(), T.chips(), T.op()) :: T.chips_with_count()
    def update(chips, delta, op \\ &Kernel.+/2) do
        delta
        |> Enum.reduce(chips, fn {colour, points}, chips -> change(chips, colour, op, points) end)
    end


    @spec change(T.chips_with_count(), T.colour(), T.op()) :: T.chips_with_count()
    def change(chips, colour, op \\ &Kernel.+/2, n \\ 1) do
        chips
        |> Map.update!(colour, &op.(&1, n))
        |> Map.update!(:count, &op.(&1, n))
    end
end
