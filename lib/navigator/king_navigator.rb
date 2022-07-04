# frozen_string_literal: true

require_relative '../piece_navigator'
require_relative '../moves'

# This class handles collision for King pieces.
class KingNavigator < PieceNavigator
  attr_reader :piece

  include Moves::CollisionlessMoves

  def possible_moves
    collisionless_moves + castling_moves
  end

  def can_castle_kingside?
    rooks = board.board.values.map(&:piece).select { |piece| piece.instance_of?(Rook) && piece.colour == @piece.colour }
    rooks.any? { |rook| rook.position.column == 'h' && rook.can_castle? } && kingside_path_free?
  end

  def can_castle_queenside?
    rooks = board.board.values.map(&:piece).select { |piece| piece.instance_of?(Rook) && piece.colour == @piece.colour }
    rooks.any? { |rook| rook.position.column == 'a' && rook.can_castle? } && queenside_path_free?
  end

  def castling_moves
    moves = []
    return moves unless piece.can_castle?

    moves << piece.position.right.right.to_s if can_castle_kingside?
    moves << piece.position.left.left.to_s if can_castle_queenside?
    moves
  end

  def queenside_path_free?
    return true if free_queenside_coordinates.length == 3

    false
  end

  def kingside_path_free?
    return true if free_kingside_coordinates.length == 2

    false
  end

  def free_queenside_coordinates
    queue = [piece.position.left]
    moves = []
    3.times do
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move.to_s unless current_square.occupied?
      queue.push(move.left) if passable?(move.left.to_s, current_square)
    end
    moves
  end

  def free_kingside_coordinates
    queue = [piece.position.right]
    moves = []
    2.times do
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move.to_s unless current_square.occupied?
      queue.push(move.right) if passable?(move.right.to_s, current_square)
    end
    moves
  end
end
