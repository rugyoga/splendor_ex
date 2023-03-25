defmodule Splendor.Card do
    alias Splendor.Card

    @colours ~w(black blue green red white)a
    @type colour :: :black | :blue | :green | :red | :white
    @type prequisites :: %{ colour => integer() }
    defstruct level: 0, colour: nil, points: 0, required: %{black: 0, blue: 0, green: 0, red: 0, white: 0}

    @type t :: %__MODULE__{
        level: non_neg_integer(),
        colour: colour(),
        points: non_neg_integer(),
        required: prequisites()}

    @spec colours() :: list(colour())
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

    def map_element({"colour", value}), do: {:colour, value |> String.downcase |> String.to_existing_atom}
    def map_element({key, value}), do: {String.to_existing_atom(key), value |> String.to_integer}
end
