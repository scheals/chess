# frozen_string_literal: true

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def possible_moves(piece)
    in_bounds = in_bounds_coordinates(piece)
    case piece.class.to_s
    when 'Pawn'
      moves_after_collision = handle_collision(piece.split_moves(mark_occupied(piece, in_bounds)))
      moves = handle_pawn(moves_after_collision)
    else
      moves = handle_collision(piece.split_moves(mark_occupied(piece, in_bounds)))
    end
    clean(moves.compact.flatten)
  end

  def clean(coordinates)
    coordinates.map { |coordinate| coordinate[0..1] }
  end

  def handle_collision(moves)
    moves.map { |direction| handle_allies(direction) }.map { |direction| handle_enemies(direction) }
  end

  def handle_pawn(moves)
    moves.map!(&:to_a)
    takes = (moves[1] + moves[2]).select { |coordinate| coordinate.end_with?('E') }
    forward = moves[0].reject { |coordinate| coordinate.end_with?('E') }
    [forward, takes]
  end

  def handle_enemies(direction)
    direction.slice_after { |coordinate| coordinate.end_with?('E') }.first
  end

  def handle_allies(direction)
    direction.take_while { |coordinate| !coordinate.end_with?('A') }
  end

  def mark_occupied(piece, coordinates)
    allies = allied_coordinates(piece)
    enemies = enemy_coordinates(piece)
    coordinates.map do |coordinate|
      next "#{coordinate}A" if allies.include?(coordinate)

      next "#{coordinate}E" if enemies.include?(coordinate)

      coordinate
    end
  end

  def in_bounds_coordinates(piece)
    board.coordinates.select { |coordinate| piece.legal?(coordinate) }
  end

  def occupied_coordinates(piece)
    in_bounds_coordinates(piece).select { |coordinate| board.find(coordinate).occupied? }
  end

  def allied_coordinates(current_piece)
    occupied_coordinates(current_piece).select { |coordinate| current_piece.colour == board.find_piece(coordinate).colour }
  end

  def enemy_coordinates(piece)
    occupied_coordinates(piece) - allied_coordinates(piece)
  end
end
