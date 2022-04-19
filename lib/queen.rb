# frozen_string_literal: true

require_relative 'piece'

# This class handles a Queen chesspiece.
class Queen < Piece
  def legal?(space)
    return false if space == position

    on_diagonal?(space) || horizontal?(space)
  end

  def on_diagonal?(space)
    vertical_distance = (space[1].to_i - row.to_i).abs
    horizontal_distance = (space[0].ord - column.ord).abs
    vertical_distance == horizontal_distance
  end

  def horizontal?(space)
    if space[0] == column
      true
    else
      space[1] == row
    end
  end
end
