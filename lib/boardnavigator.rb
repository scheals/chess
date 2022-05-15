# frozen_string_literal: true

require_relative 'board'

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board

  def initialize(board)
    @board = board
  end

  # rubocop: disable all
  def possible_moves(piece)
    case piece.class.to_s
    when 'Knight'
      in_bounds_coordinates(piece) - allied_coordinates(piece)
    when 'King'
      in_bounds_coordinates(piece) - allied_coordinates(piece)
    when 'Rook'
      in_bounds = in_bounds_coordinates(piece)
      occupied = occupied_coordinates(piece)
      allies = allied_coordinates(piece)
      enemies = enemy_coordinates(piece)
      baseline = in_bounds
      moves = []
      horizontal_and_vertical(piece, baseline).each { |direction| moves << enemies_and_allies(piece, direction) }
      moves_without_allies = []
      moves.each { |direction| moves_without_allies << remove_allies(direction) }
      moves_with_legal_enemies = []
      moves_without_allies.each { |direction| moves_with_legal_enemies << handle_enemies(direction) }
      enemy_to_coordinate(moves_with_legal_enemies.compact.flatten)
    else
      []
    end
  end
# rubocop: enable all

  def enemy_to_coordinate(coordinates)
    coordinates.map { |coordinate| coordinate[0..1] }
  end

  def handle_enemies(direction)
    direction.slice_after { |coordinate| coordinate.end_with?('E') }.to_a.first
  end

  def remove_allies(direction)
    direction.take_while { |coordinate| !coordinate.end_with?('A') }
  end

  def horizontal_and_vertical(piece, baseline)
    moves = []
    moves << up(piece, baseline)
    moves << down(piece, baseline).reverse
    moves << left(piece, baseline).reverse
    moves << right(piece, baseline)
    moves
  end

  def up(piece, baseline)
    baseline.select { |coordinate| coordinate[1].to_i > piece.position[1].to_i }
  end

  def down(piece, baseline)
    baseline.select { |coordinate| coordinate[1].to_i < piece.position[1].to_i }
  end

  def left(piece, baseline)
    baseline.select { |coordinate| coordinate[0].ord < piece.position[0].ord }
  end

  def right(piece, baseline)
    baseline.select { |coordinate| coordinate[0].ord > piece.position[0].ord }
  end

  def enemies_and_allies(piece, direction)
    allies = allied_coordinates(piece)
    enemies = enemy_coordinates(piece)
    direction.map do |coordinate|
      next "#{coordinate}A" if allies.include?(coordinate)

      next "#{coordinate}E" if enemies.include?(coordinate)

      coordinate
    end
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
test = BoardNavigator.new(Board.new)
bishop = Bishop.new('e4', colour: 'white')
p test.in_bounds_coordinates(bishop)
