defmodule Splendor.Hand do
    alias Splendor.Hand

    def increment(x), do: x+1

    defstruct points: 0, 
        chips: %{black: 0, blue: 0, gold: 0, green: 0, red: 0, white: 0, count: 0}, 
        bought: [], 
        reserved: []

    def reserve(hand, card) do
        %Hand{ hand |
            reserved: [card | hand.reserved],
            chips: hand.chips |> Map.update!(:gold, &increment/1) |> Map.update!(:count, &increment/1)
        }
    end

    def buy(hand, card) do
        %Hand{ hand | 
            points: hand.points + card.points,
            chips: change(hand.chips, card.required, &Kernel.-/2),
            bought: [card | hand.bought]
        }
    end
    
    def get_chips(hand, chips), do: %Hand{
        hand | chips: change(hand.chips, chips)}

    def change(original, delta, op \\ &Kernel.+/2) do
        delta |> Enum.reduce(original, fn {colour, points}, chips -> chips |> Map.update!(colour, &op.(&1, points)) end)
    end
end