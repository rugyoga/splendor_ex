defmodule Splendor.Game do
    @moduledoc """
    Represents a Splendor game state
    """

    alias Splendor.{Card, Game, Hand, T}

    defstruct turn: 0,
        chips: %{black: 7, blue: 7, gold: 5, green: 7, red: 7, white: 7},
        cards: Splendor.Card.deck(),
        moves: []

    @type t :: %__MODULE__{
        chips: T.chips(),
        cards: T.cards(),
        moves: T.moves()
    }

    @type move_gen :: (T.game_state() -> T.moves())

    @max_hand_size 10
    @solitaire true

    # @spec push(PriorityQueue.t(), T.game_state()) :: PriorityQueue.t()
    # def push(pq, state), do: PriorityQueue.push(pq, state, score(state))

    def start(), do: {%Game{}, %Hand{}}

    def next_states(state = {_game, _hand}, move_gen \\ &moves_solitaire/1) do
        move_gen.(state)
    end


    # @spec score(T.game_state()) :: integer()
    # def score({game, hand}), do: - (100 * game.turn + 10 * hand.points + hand.chips.count)

    @doc """
    Generate moves for solitaire version

    ## Examples

        iex> Game.start() |> Game.moves_solitaire() |> length()
        15

    """
    @spec moves_solitaire(T.game_state()) :: T.moves()
    def moves_solitaire(state), do: grab_chips(state) ++ buy_a_card(state)

    @doc """
    Generate moves for solitaire version

    ## Examples

        iex> Game.start() |> Game.moves_regular() |> length()
        105

    """
    @spec moves_regular(T.game_state()) :: T.moves()
    def moves_regular(state), do: moves_solitaire(state) ++ reserve_a_card(state)


    def make_move({game, hand}, {:grab, chips}) do
        {game, Hand.grab(hand, chips)}
    end

    def make_move(state = {_game, _hand}, _move = {:reserve, _items}) do
        state
    end

    def make_move(state = {_game, _hand}, _move = {:buy, _items}) do
        state
    end

    def make_move(state = {_game, _hand}, _move = {:multi, _moves}) do
        state
    end

    @doc """
    Reserve card

    ## Examples

        iex> Game.reserve_a_card(Game.start())
        Card.deck() |> Enum.map(&{:reserve, &1})

    """
    @spec reserve_a_card(T.game_state()) :: list(T.reserve())
    def reserve_a_card({game, hand}) do
        if Enum.count(hand.reserved) == 3 do
            []
        else
            Enum.map(game.cards, &{:reserve, &1})
        end
    end

    @doc """
    Reserve card

    ## Examples

        iex> Game.buy_a_card(Game.start())
        []

        iex> Game.buy_a_card({%Game{}, %Hand{chips: %{black: 0, blue: 1, green: 1, red: 1, white: 1, gold: 0, count: 4}}})
        [{:buy, %Splendor.Card{level: 1, colour: :black, points: 0, required: %{black: 0, blue: 1, green: 1, red: 1, white: 1}}}]

        iex> Game.buy_a_card({%Game{}, %Hand{chips: %{black: 1, blue: 1, green: 1, red: 1, white: 1, gold: 1, count: 6}}})
        [{:buy, %Splendor.Card{colour: :black, level: 1, points: 0, required: %{black: 0, blue: 1, green: 1, red: 1, white: 1}}},
        {:buy, %Splendor.Card{level: 1, colour: :black, points: 0, required: %{black: 0, blue: 2, green: 1, red: 1, white: 1}}},
        {:buy, %Splendor.Card{level: 1, colour: :black, points: 0, required: %{black: 0, blue: 0, green: 2, red: 1, white: 0}}},
        {:buy, %Splendor.Card{level: 1, colour: :blue, points: 0, required: %{black: 1, blue: 0, green: 1, red: 1, white: 1}}},
        {:buy, %Splendor.Card{level: 1, colour: :blue, points: 0, required: %{black: 1, blue: 0, green: 1, red: 2, white: 1}}},
        {:buy, %Splendor.Card{level: 1, colour: :blue, points: 0, required: %{black: 2, blue: 0, green: 0, red: 0, white: 1}}},
        {:buy, %Splendor.Card{level: 1, colour: :white, points: 0, required: %{black: 1, blue: 1, green: 1, red: 1, white: 0}}},
        {:buy, %Splendor.Card{level: 1, colour: :white, points: 0, required: %{black: 1, blue: 1, green: 2, red: 1, white: 0}}},
        {:buy, %Splendor.Card{level: 1, colour: :white, points: 0, required: %{black: 1, blue: 0, green: 0, red: 2, white: 0}}},
        {:buy, %Splendor.Card{level: 1, colour: :green, points: 0, required: %{black: 1, blue: 1, green: 0, red: 1, white: 1}}},
        {:buy, %Splendor.Card{level: 1, colour: :green, points: 0, required: %{black: 2, blue: 1, green: 0, red: 1, white: 1}}},
        {:buy, %Splendor.Card{level: 1, colour: :green, points: 0, required: %{black: 0, blue: 1, green: 0, red: 0, white: 2}}},
        {:buy, %Splendor.Card{level: 1, colour: :red, points: 0, required: %{black: 1, blue: 1, green: 1, red: 0, white: 1}}},
        {:buy, %Splendor.Card{level: 1, colour: :red, points: 0, required: %{black: 1, blue: 1, green: 1, red: 0, white: 2}}},
        {:buy, %Splendor.Card{level: 1, colour: :red, points: 0, required: %{black: 0, blue: 2, green: 1, red: 0, white: 0}}}]
    """
    @spec buy_a_card(T.game_state()) :: T.moves()
    def buy_a_card({game, hand}) do
        game.cards
        |> Enum.filter(&Card.buyable?(&1, hand.chips))
        |> Enum.map(&{:buy, &1})
    end


    @doc """
    Grab chips chips

    ## Examples

        iex> Game.grab_chips(Game.start())
        [{:grab, %{black: 2}},
        {:grab, %{blue: 2}},
        {:grab, %{green: 2}},
        {:grab, %{red: 2}},
        {:grab, %{white: 2}},
        {:grab, %{black: 1, blue: 1, green: 1}},
        {:grab, %{black: 1, blue: 1, red: 1}},
        {:grab, %{black: 1, blue: 1, white: 1}},
        {:grab, %{black: 1, green: 1, red: 1}},
        {:grab, %{black: 1, green: 1, white: 1}},
        {:grab, %{black: 1, red: 1, white: 1}},
        {:grab, %{blue: 1, green: 1, red: 1}},
        {:grab, %{blue: 1, green: 1, white: 1}},
        {:grab, %{blue: 1, red: 1, white: 1}},
        {:grab, %{green: 1, red: 1, white: 1}}]

    """
    @spec grab_chips(T.game_state()) :: T.moves()
    def grab_chips({game, _hand} = state) do
        grab_two_chips(game.chips)
        |> Kernel.++(grab_three_chips(game.chips))
        |> Enum.flat_map(&discard_to_n(state, &1, 10))
    end

    @doc """
    Discard n chips

    ## Examples

        iex> Game.discard_to_n({%Game{}, %Hand{}}, {:grab, %{black: 1, blue: 1, green: 1}}, 2)
        []

        iex> Game.discard_to_n({%Game{}, %Hand{}}, {:grab, %{black: 1, blue: 1, green: 1}}, 3)
        [{:grab, %{black: 1, blue: 1, green: 1}}]

        iex> Game.discard_to_n({%Game{}, %Hand{chips: %{black: 2, blue: 2, green: 2, red: 2, white: 2, gold: 0, count: 10}}}, {:grab, %{black: 1, blue: 1, green: 1}}) |> length()
        33
    """
    @spec discard_to_n(T.game_state(), T.grab(), integer()) :: T.moves()
    def discard_to_n({_game, hand}, {:grab, chips} = move, n \\ @max_hand_size) do
        hand = Hand.grab(hand, chips)
        if hand.chips.count > n do
            hand.chips
            |> Map.delete(:count)
            |> discard(hand.chips.count - 10)
            |> Enum.map(&{:multi, move, &1})
        else
            [move]
        end
    end

    @doc """
    Discard n chips

    ## Examples

        iex> Game.discard(%{black: 0, blue: 0, green: 0, red: 0, white: 0}, 0, [])
        [{:discard, %{}}]

        iex> Game.discard(%{black: 1, blue: 0, green: 0, red: 0, white: 0}, 1, [])
        [[discard: %{black: 1}]]
    """
    @spec discard(T.chips(), integer(), T.colours()) :: list()
    def discard(_chips, 0, discards), do: [{:discard, Enum.frequencies(discards)}]
    def discard(chips, discard, discards) do
        chips
        |> Enum.filter(fn {_colour, n} -> n > 0 end)
        |> Enum.map(fn {colour, _} -> discard(Map.update!(chips, colour, &(&1 - 1)), discard - 1, [colour | discards]) end)
    end

    @doc """
    Discard n chips

    ## Examples

        iex> Game.discard(%{black: 0, blue: 0, green: 0, red: 0, white: 0}, 0)
        []

        iex> Game.discard(%{black: 1, blue: 0, green: 0, red: 0, white: 0}, 1)
        [{:discard, %{black: 1}}]

        iex> Game.discard(%{black: 1, blue: 1, green: 1, red: 1, white: 1}, 1)
        [{:discard, %{black: 1}},
         {:discard, %{blue: 1}},
         {:discard, %{green: 1}},
         {:discard, %{red: 1}},
         {:discard, %{white: 1}}]

        iex> Game.discard(%{black: 1, blue: 1, green: 1, red: 1, white: 1}, 2)
        [{:discard, %{black: 1, blue: 1}},
         {:discard, %{black: 1, green: 1}},
         {:discard, %{black: 1, red: 1}},
         {:discard, %{black: 1, white: 1}},
         {:discard, %{blue: 1, green: 1}},
         {:discard, %{blue: 1, red: 1}},
         {:discard, %{blue: 1, white: 1}},
         {:discard, %{green: 1, red: 1}},
         {:discard, %{green: 1, white: 1}},
         {:discard, %{red: 1, white: 1}}]

        iex> Game.discard(%{black: 1, blue: 1, green: 1, red: 1, white: 1}, 3)
        [{:discard, %{black: 1, blue: 1, green: 1}},
         {:discard, %{black: 1, blue: 1, red: 1}},
         {:discard, %{black: 1, blue: 1, white: 1}},
         {:discard, %{black: 1, green: 1, red: 1}},
         {:discard, %{black: 1, green: 1, white: 1}},
         {:discard, %{black: 1, red: 1, white: 1}},
         {:discard, %{blue: 1, green: 1, red: 1}},
         {:discard, %{blue: 1, green: 1, white: 1}},
         {:discard, %{blue: 1, red: 1, white: 1}},
         {:discard, %{green: 1, red: 1, white: 1}}]

        iex> Game.discard(%{black: 1, blue: 1, green: 1, red: 1, white: 1}, 4)
        [{:discard, %{black: 1, blue: 1, green: 1, red: 1}},
         {:discard, %{black: 1, blue: 1, green: 1, white: 1}},
         {:discard, %{black: 1, blue: 1, red: 1, white: 1}},
         {:discard, %{black: 1, green: 1, red: 1, white: 1}},
         {:discard, %{blue: 1, green: 1, red: 1, white: 1}}]

        iex> Game.discard(%{black: 1, blue: 1, green: 1, red: 1, white: 1}, 5)
        [{:discard, %{black: 1, blue: 1, green: 1, red: 1, white: 1}}]

        iex> Game.discard(%{black: 2, blue: 2, green: 2}, 2)
        [{:discard, %{black: 2}},
         {:discard, %{black: 1, blue: 1}},
         {:discard, %{black: 1, green: 1}},
         {:discard, %{blue: 2}},
         {:discard, %{blue: 1, green: 1}},
         {:discard, %{green: 2}}]

        iex> Game.discard(%{black: 2, blue: 2, green: 2}, 3)
        [{:discard, %{black: 2, blue: 1}},
         {:discard, %{black: 2, green: 1}},
         {:discard, %{black: 1, blue: 2}},
         {:discard, %{black: 1, blue: 1, green: 1}},
         {:discard, %{black: 1, green: 2}},
         {:discard, %{blue: 2, green: 1}},
         {:discard, %{blue: 1, green: 2}}]
    """
    @spec discard(T.chips(), integer()) :: T.moves()
    def discard(_, 0), do: []
    def discard(chips, n), do: chips |> discard(n, []) |> List.flatten |> Enum.uniq()

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
    @spec grab_two_chips(T.chips()) :: T.moves()
    def grab_two_chips(chips) do
        Card.colours
        |> Enum.filter(&(Map.get(chips, &1) >= 4))
        |> Enum.map(&{:grab, %{&1 => 2}})
    end

    @doc """
    Generate all ways to grab three chips from the available supply

    ## Examples

        iex> Game.grab_three_chips(%{black: 1, blue: 1, green: 1, red: 0, white: 0})
        [{:grab, %{black: 1, blue: 1, green: 1}}]

        iex> Game.grab_three_chips(%{black: 1, blue: 1, green: 1, red: 1, white: 0})
        [{:grab, %{black: 1, blue: 1, green: 1}},
        {:grab, %{black: 1, blue: 1, red: 1}},
        {:grab, %{black: 1, green: 1, red: 1}},
        {:grab, %{blue: 1, green: 1, red: 1}}]

        iex> Game.grab_three_chips(%{black: 1, blue: 1, green: 1, red: 1, white: 1})
        [{:grab, %{black: 1, blue: 1, green: 1}},
        {:grab, %{black: 1, blue: 1, red: 1}},
        {:grab, %{black: 1, blue: 1, white: 1}},
        {:grab, %{black: 1, green: 1, red: 1}},
        {:grab, %{black: 1, green: 1, white: 1}},
        {:grab, %{black: 1, red: 1, white: 1}},
        {:grab, %{blue: 1, green: 1, red: 1}},
        {:grab, %{blue: 1, green: 1, white: 1}},
        {:grab, %{blue: 1, red: 1, white: 1}},
        {:grab, %{green: 1, red: 1, white: 1}}]
    """
    @spec grab_three_chips(T.chips()) :: T.moves()
    def grab_three_chips(chips) do
        Card.colours
        |> Enum.filter(&(Map.get(chips, &1) > 0))
        |> pick(3)
        |> Enum.map(fn colours -> {:grab, colours |> Enum.map(&{&1, 1}) |> Map.new} end)
    end

    def pick(_, 0, so_far), do: [{Enum.reverse(so_far)}]
    def pick([], _, _), do: []
    def pick([item | items], n, so_far), do: [pick(items, n - 1, [item | so_far]), pick(items, n, so_far)]

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
    @spec pick([t()], integer()) :: [t()] when t: var
    def pick(items, n) do
        if Enum.count(items) <= n do
            [items]
        else
            pick(items, n, []) |> List.flatten |> Enum.map(fn {x} -> x end)
        end
    end

end
