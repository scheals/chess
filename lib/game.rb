# frozen_string_literal: true

# This class handles a game of Chess.
class Game
  attr_reader :board

  def initialize(board = Board.new.board)
    @board = board
  end
end
