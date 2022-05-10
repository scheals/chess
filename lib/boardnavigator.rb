# frozen_string_literal: true

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def in_bounds_moves(piece)
    board_coordinates = board.board.keys
    board_coordinates.select { |coordinate| piece.legal?(coordinate) }
  end
end