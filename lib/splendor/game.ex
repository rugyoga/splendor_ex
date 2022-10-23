defmodule Splendor.Game do
    alias Splendor.{Card,Game,Hand}

    defstruct turn: 0,
        chips: %{black: 7, blue: 7, gold: 5, green: 7, red: 7, white: 7}, 
        cards: Splendor.Card.deck(),
        moves: []

    def choices(_game, hand) when hand.points >= 15, do: [{:finished, hand}]
    #def choices

    def search() do
        PriorityQueue.new |> push(start())
    end

    def push(pq, state), do: PriorityQueue.push(pq, state, score(state))

    def start, do: {%Hand{}, %Game{}}

    def score({hand, game}), do: - (100 * game.turn + 10 * hand.points + hand.chips.count)

    def moves({_hand, _game}) do
        #grab chips
        #reserve a card
        #buy a card
    end

    def reserve_a_card({hand, game}) do
        if game.chips.gold

    def grab_chips(state) do
        grab_two_chips(state) ++ grab_three_chips(state)
        |> Enum.flat_map(&discard_to_10/1)
    end

    def discard_to_10(x) do
        x
    end

    @doc """
    Find all the grab two chip moves

    ## Examples

        iex> Game.grab_two_chips(%{black: 0, blue: 0, green: 0, red: 0, white: 0})
        []

        iex> Game.grab_two_chips(%{black: 4, blue: 4, green: 4, red: 4, white: 4})
        [{:grab, %{black: 2}},
        {:grab, %{blue: 2}},
        {:grab, %{green: 2}},
        {:grab, %{red: 2}},
        {:grab, %{white: 2}}]
    """
    def grab_two_chips(chips) do
        Card.colours
        |> Enum.filter(&(Map.get(chips, &1) >= 4))
        |> Enum.map(&{:grab, %{&1 => 2}})
    end

    @doc """
    Generate all wasys to grab three chips from the available supply

    ## Examples

        iex> Game.grab_three_chips(%{black: 1, blue: 1, green: 1, red: 0, white: 0})
        [{:grab, %{black: 1, blue: 1, green: 1}}]
    """
    def grab_three_chips(chips) do
        Card.colours
        |> Enum.filter(&(Map.get(chips, &1) > 0))
        |> IO.inspect(label: "after_filter")
        |> pick(3)
        |> Enum.map(fn colours -> {:grab, Enum.map(colours, &{&1, 1}) |> Map.new} end)
    end

    def pick(_, 0, so_far), do: [{Enum.reverse(so_far)}]
    def pick([], _, _), do: []
    def pick([item | items], n, so_far), do: [pick(items, n-1, [item|so_far]), pick(items, n, so_far)]

    @doc """
    Find all the different way to pick n distinct coins from items

    ## Examples

        iex> Game.pick([:a,:b,:c,:d], 3)
        [[:a,:b,:c], [:a,:b,:d], [:a,:c,:d], [:b,:c,:d]]
        
        iex> Game.pick([:a,:b,:c,:d], 4)
        [[:a,:b,:c, :d]]
                
        iex> Game.pick([:a,:b,:c,:d], 5)
        [[:a,:b,:c, :d]]
    """
    def pick(items, n) do
        if Enum.count(items) <= n do
            [items]
        else
            pick(items, n, []) |> List.flatten |> Enum.map(fn {x} -> x end)
        end
    end

end