# frozen_string_literal: true

# This class handles collision rules for Pieces
class PieceNavigator
  attr_reader :board, :piece

  def initialize(board, piece)
    @board = board
    @piece = piece
  end

  def possible_moves
    raise 'NotImplemented'
  end

  def legal_for(piece)
    piece.legal(board.coordinates)
  end

  def handle_collision(piece, directions)
    allies = allied_coordinates(piece)
    enemies = enemy_coordinates(piece)
    directions.map do |direction|
      handle_allies(direction, allies)
    end.map { |direction| handle_enemies(direction, enemies) }
  end

  def occupied_coordinates(piece, coordinates = legal_for(piece))
    coordinates.select { |coordinate| board.find(coordinate.to_s).occupied? }
  end

  def allied_coordinates(piece, coordinates = occupied_coordinates(piece))
    coordinates.select { |coordinate| piece.ally?(board.find_piece(coordinate.to_s)) }
  end

  def enemy_coordinates(piece, coordinates = occupied_coordinates(piece))
    coordinates.select { |coordinate| piece.enemy?(board.find_piece(coordinate.to_s)) }
  end

  def handle_allies(direction, allies)
    direction.take_while { |coordinate| !allies.include?(coordinate.to_s) }
  end

  def handle_enemies(direction, enemies)
    direction.slice_after { |coordinate| enemies.include?(coordinate.to_s) }.first
  end
end
