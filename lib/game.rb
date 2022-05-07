# frozen_string_literal: true

# This class handles a game of Chess.
class Game
  def initialize(board = Board.new.board)
    @board = board
  end

  def put(piece, coordinates)
    find(coordinates).place(piece)
  end

  def find(coordinates)
    @board[coordinates]
  end
end
