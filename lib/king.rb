# frozen_string_literal: true

require_relative 'piece'

# This class handles a Queen chesspiece.
class King < Piece
  attr_reader :position

  def legal?(space)
    return false if space == position

    if (space[0].succ == column || column.succ == space[0]) || (space[1].to_i - row.to_i).abs == 1
      true
    else
      false
    end
  end
end
