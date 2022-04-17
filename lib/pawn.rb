# frozen_string_literal: true

require_relative 'piece'

# This class handles a Pawn chesspiece rules.
class Pawn < Piece
  def legal?(space)
    return false if space == position

    if once_horizontal(space)
      return true if black_vertical(space)
      return true if white_vertical(space)
    end
    return true if black_vertical(space)
    return true if white_vertical(space)
  end

  def black_vertical(space)
    (space[1].to_i - row.to_i) == -1
  end

  def white_vertical(space)
    (space[1].to_i - row.to_i) == 1
  end

  def once_horizontal(space)
    space[0].succ == column || column.succ == space[0]
  end
end
