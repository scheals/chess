# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Rook pieces.
class RookNavigator < PieceNavigator
  attr_reader :piece

  def possible_moves
    coordinates = legal_for(piece)
    handle_collision(piece.split_moves(coordinates)).compact.flatten
  end

  def go_left
    queue = [piece.position.left]
    moves = []
    until queue.empty?
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move.to_s if empty_or_enemy?(current_square)
      queue.push(move.left) if passable?(move.left.to_s, current_square)
    end
    moves
  end

  def empty_or_enemy?(square)
    !square.occupied? || piece.enemy?(square.piece)
  end

  def passable?(move, square)
    board.in_bounds?(move) && !square.occupied?
  end
end
