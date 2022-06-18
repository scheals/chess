# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Bishop pieces.
class BishopNavigator < PieceNavigator
  attr_reader :piece

  def possible_moves
    go_up_left + go_up_right + go_down_left + go_down_right
  end

  def go_up_left
    queue = [piece.position.up.left]
    moves = []
    until queue.empty?
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move if empty_or_enemy?(current_square)
      queue.push(move.up.left) if passable?(move.up.left.to_s, current_square)
    end
    moves
  end

  def go_up_right
    queue = [piece.position.up.right]
    moves = []
    until queue.empty?
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move if empty_or_enemy?(current_square)
      queue.push(move.up.right) if passable?(move.up.right.to_s, current_square)
    end
    moves
  end

  def go_down_left
    queue = [piece.position.down.left]
    moves = []
    until queue.empty?
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move if empty_or_enemy?(current_square)
      queue.push(move.down.left) if passable?(move.down.left.to_s, current_square)
    end
    moves
  end

  def go_down_right
    queue = [piece.position.down.right]
    moves = []
    until queue.empty?
      move = queue.shift
      current_square = board.find(move.to_s)
      break unless current_square

      moves << move if empty_or_enemy?(current_square)
      queue.push(move.down.right) if passable?(move.down.right.to_s, current_square)
    end
    moves
  end
end
