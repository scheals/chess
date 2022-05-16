# frozen_string_literal: true

require_relative 'piece'

# This class handles a Bishop chesspiece
class Bishop < Piece
  def legal?(space)
    return false if space == position

    on_diagonal?(space)
  end

  def split_moves(moves)
    split_moves = []
    split_moves << left_up(moves).reverse
    split_moves << left_down(moves).reverse
    split_moves << right_up(moves)
    split_moves << right_down(moves)
    split_moves
  end

  def left_up(moves)
    moves.select { |coordinate| coordinate[1].to_i > position[1].to_i && coordinate[0].ord < position[0].ord }
  end

  def left_down(moves)
    moves.select { |coordinate| coordinate[1].to_i < position[1].to_i && coordinate[0].ord < position[0].ord }
  end

  def right_up(moves)
    moves.select { |coordinate| coordinate[1].to_i > position[1].to_i && coordinate[0].ord > position[0].ord }
  end

  def right_down(moves)
    moves.select { |coordinate| coordinate[1].to_i < position[1].to_i && coordinate[0].ord > position[0].ord }
  end

  def on_diagonal?(space)
    vertical_distance = (space[1].to_i - row.to_i).abs
    horizontal_distance = (space[0].ord - column.ord).abs
    vertical_distance == horizontal_distance
  end
end
