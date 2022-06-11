# frozen_string_literal: true

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def possible_moves(piece)
    if piece.is_a?(Pawn)
      handle_pawn(piece)
    else
      coordinates = legal_for(piece)
      handle_collision(piece, piece.split_moves(coordinates)).compact.flatten
    end
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

  def handle_pawn(piece)
    if piece.colour == 'white'
      handle_white_pawn(piece)
    else
      handle_black_pawn(piece)
    end
  end

  def handle_white_pawn(piece)
    takes = enemy_coordinates(piece, [piece.position.left.up, piece.position.right.up])
    forward = [piece.position.up, piece.position.up.up].slice_after do |coordinate|
      board.find(coordinate.to_s).occupied?
    end.first
    forward + takes
  end

  def handle_black_pawn(piece)
    takes = enemy_coordinates(piece, [piece.position.left.down, piece.position.right.down])
    forward = [piece.position.down, piece.position.down.down].slice_after do |coordinate|
      board.find(coordinate.to_s).occupied?
    end.first
    forward + takes
  end
end
