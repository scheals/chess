# frozen_string_literal: true

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def possible_moves(piece)
    marked_moves = mark_occupied(piece)
    moves = piece.handle_collision(marked_moves)
    clean(moves.compact.flatten)
  end

  def clean(coordinates)
    coordinates.map { |coordinate| coordinate[0..1] }
  end

  def mark_occupied(piece)
    coordinates = piece.legal(board.coordinates)
    allies = allied_coordinates(piece)
    enemies = enemy_coordinates(piece)
    coordinates.map do |coordinate|
      next "#{coordinate}A" if allies.include?(coordinate)

      next "#{coordinate}E" if enemies.include?(coordinate)

      coordinate
    end
  end

  def occupied_coordinates(piece)
    piece.legal(board.coordinates).select { |coordinate| board.find(coordinate).occupied? }
  end

  def allied_coordinates(piece)
    colour = piece.colour
    occupied_coordinates(piece).select { |coordinate| colour == board.find_piece(coordinate).colour }
  end

  def enemy_coordinates(piece)
    colour = piece.colour
    occupied_coordinates(piece).reject { |coordinate| colour == board.find_piece(coordinate).colour }
  end
end
