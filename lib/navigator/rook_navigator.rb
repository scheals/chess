# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Rook pieces.
class RookNavigator < PieceNavigator
  attr_reader :piece

  def possible_moves
    go_left + go_right + go_up + go_down
  end

  def go_left
    queue = [piece.position.left]
    moves = []
    until queue.empty?
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move if empty_or_enemy?(current_square)
      queue.push(move.left) if passable?(move.left.to_s, current_square)
    end
    moves
  end

  def go_right
    queue = [piece.position.right]
    moves = []
    until queue.empty?
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move if empty_or_enemy?(current_square)
      queue.push(move.right) if passable?(move.right.to_s, current_square)
    end
    moves
  end

  def go_up
    queue = [piece.position.up]
    moves = []
    until queue.empty?
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move if empty_or_enemy?(current_square)
      queue.push(move.up) if passable?(move.up.to_s, current_square)
    end
    moves
  end

  def go_down
    queue = [piece.position.down]
    moves = []
    until queue.empty?
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move if empty_or_enemy?(current_square)
      queue.push(move.down) if passable?(move.down.to_s, current_square)
    end
    moves
  end
end
