defmodule Splendor.T do
  @moduledoc """
  Useful types
  """

  alias Splendor.{Card, Game, Hand}

  @type buy :: {:buy, Card.t()}
  @type cards :: list(Card.t())
  @type colour :: :black | :blue  | :gold | :green | :red | :white
  @type colours :: list(colour())
  @type chips :: %{colour() => integer()}
  @type chips_with_count :: %{(colours() | :count) => integer()}
  @type discard :: {:discard, colours()}
  @type grab :: {:grab, chips()}
  @type move :: buy() | discard() | grab() | multi() | reserve()
  @type moves :: list(move())
  @type multi :: {:multi, move(), move()}
  @type op :: (integer(), integer() -> integer())
  @type reserve :: {:reserve, Card.t()}
  @type game_state :: {Game.t(), Hand.t()}
end
