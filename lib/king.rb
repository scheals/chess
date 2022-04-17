# frozen_string_literal: true

require_relative 'piece'

# This class handles a Queen chesspiece.
class King < Piece
  def legal?(space)
    return false if space == position

    if once_horizontal(space) || once_vertical(space)
      true
    else
      false
    end
  end

  def once_vertical(space)
    (space[1].to_i - row.to_i).abs == 1
  end

  def once_horizontal(space)
    space[0].succ == column || column.succ == space[0]
  end
end
