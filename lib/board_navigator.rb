# frozen_string_literal: true

require_relative 'navigator_factory'

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board, :navigator_factory

  def initialize(board, navigator_factory = NavigatorFactory)
    @board = board
    @navigator_factory = navigator_factory
  end

  def moves_for(coordinate)
    return nil unless piece_for(coordinate)

    navigator = navigator_factory.for(board, piece_for(coordinate))
    navigator.possible_moves
  end

  def piece_for(coordinate)
    board.find_piece(coordinate)
  end
end
