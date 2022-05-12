# frozen_string_literal: true

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def possible_moves(piece)
    in_bounds_coordinates(piece) - allied_coordinates(piece)
  end

  def in_bounds_coordinates(piece)
    board_coordinates = board.coordinates
    board_coordinates.select { |coordinate| piece.legal?(coordinate) }
  end

  def occupied_coordinates(piece)
    all_coordinates = in_bounds_coordinates(piece)
    all_coordinates.select { |coordinate| board.find(coordinate).occupied? }
  end

  def allied_coordinates(current_piece)
    occupied_coordinates(current_piece).select { |coordinate| current_piece.colour == board.find_piece(coordinate).colour }
  end

  def enemy_coordinates(piece)
    occupied_coordinates(piece) - allied_coordinates(piece)
  end
end
