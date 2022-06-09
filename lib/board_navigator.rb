# frozen_string_literal: true

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def possible_moves(piece)
    coordinates = piece.legal(board.coordinates)
    handle_collision(piece, piece.split_moves(coordinates)).compact.flatten
  end

  def clean(coordinates)
    coordinates.map { |coordinate| coordinate[0..1] }
  end

  def handle_collision(piece, directions)
    allies = allied_coordinates(piece)
    enemies = enemy_coordinates(piece)
    directions.map { |direction| handle_allies(direction, allies) }.map { |direction| handle_enemies(direction, enemies) }
  end

  def occupied_coordinates(piece)
    piece.legal(board.coordinates).select { |coordinate| board.find(coordinate.to_s).occupied? }
  end

  def allied_coordinates(piece)
    colour = piece.colour
    occupied_coordinates(piece).select { |coordinate| colour == board.find_piece(coordinate).colour }
  end

  def enemy_coordinates(piece)
    colour = piece.colour
    occupied_coordinates(piece).reject { |coordinate| colour == board.find_piece(coordinate).colour }
  end

  def handle_allies(direction, allies)
    direction.take_while { |coordinate| !allies.include?(coordinate.to_s) }
  end

  def handle_enemies(direction, enemies)
    direction.slice_after { |coordinate| enemies.include?(coordinate.to_s) }.first
  end
end
