# frozen_string_literal: true

require_relative 'navigator_factory'

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board, :navigator_factory, :coordinate_system

  def initialize(board, navigator_factory = NavigatorFactory, coordinate_system = Coordinate)
    @board = board
    @navigator_factory = navigator_factory
    @coordinate_system = coordinate_system
  end

  def moves_for(coordinate)
    return nil unless piece_for(coordinate)

    navigator = navigator_factory.for(board, piece_for(coordinate))
    navigator.possible_moves
  end

  def piece_for(coordinate)
    board.find_piece(coordinate)
  end

  def under_check?(king)
    king_navigator = navigator_factory.for(board, king)

    return true if enemy_moves(king_navigator).any? { |moves| moves.include?(king.position) }

    false
  end

  def enemy_moves(piece_navigator)
    piece_navigator.enemy_coordinates(board.coordinates).map { |coordinate| moves_for(coordinate) }
  end
end
