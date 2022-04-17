# frozen_string_literal: true

require_relative 'piece'

# This class handles a Knight chesspiece rules.
class Knight < Piece
  def legal?(space)
    return false if space == position

    if twice_vertical(space) && once_horizontal(space) || twice_horizontal(space) && once_vertical(space)
      true
    else
      false
    end
  end

  def twice_vertical(space)
    (space[1].to_i - row.to_i).abs == 2
  end

  def once_vertical(space)
    (space[1].to_i - row.to_i).abs == 1
  end

  def twice_horizontal(space)
    space[0].succ.succ == column || column.succ.succ == space[0]
  end

  def once_horizontal(space)
    space[0].succ == column || column.succ == space[0]
  end
end
