defmodule Splendor.Card do
    @moduledoc """
    Represents a Splendor card
    """

    alias Splendor.{Card, T}

    @colours ~w(black blue green red white)a

    defstruct level: 0, colour: nil, points: 0, required: %{black: 0, blue: 0, green: 0, red: 0, white: 0}

    @type t :: %__MODULE__{
        level: integer(),
        colour: T.colour(),
        points: integer(),
        required: T.chips()}

    @spec colours() :: list(T.colour())
    def colours, do: @colours

    @spec deck() :: list(t())
    def deck do
        "deck.csv"
        |> File.stream!()
        |> CSV.decode!(headers: true)
        |> Enum.map(fn csv -> csv |> Map.to_list |> Enum.map(&map_element/1) |> Map.new end)
        |> Enum.map(fn csv ->
            %Card{
                level: csv.level,
                colour: csv.colour,
                points: csv.points,
                required: Map.new(@colours, &{&1, Map.get(csv, &1)})
                }
            end)
    end

    @spec buyable?(t(), T.chips()) :: boolean()
    def buyable?(card, chips) do
        calculate_deficit = fn {colour, count}, deficit -> deficit + Enum.max([0, count - chips[colour]]) end
        Enum.reduce(card.required, 0, calculate_deficit) <= chips.gold
    end

    @spec map_element({binary(), binary()}) :: {atom(), integer() | atom()}
    def map_element({"colour", value}), do: {:colour, value |> String.downcase |> String.to_existing_atom}
    def map_element({key, value}), do: {String.to_existing_atom(key), value |> String.to_integer}
end
