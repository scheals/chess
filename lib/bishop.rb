# frozen_string_literal: true

require_relative 'piece'

# This class handles a Bishop chesspiece
class Bishop < Piece
  def legal?(space)
    return false if space == position

    on_diagonal?(space)
  end

  def on_diagonal?(space)
    vertical_distance = (space[1].to_i - row.to_i).abs
    horizontal_distance = (space[0].ord - column.ord).abs
    vertical_distance == horizontal_distance
  end
end
