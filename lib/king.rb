# frozen_string_literal: true

require_relative 'piece'

# This class handles a King chesspiece.
class King < Piece
  def legal?(space)
    return false if space == position

    once_diagonal?(space) || (once_horizontal?(space) && same_row?(space)) || (once_vertical?(space) && same_column?(space))
  end

  def split_moves(moves)
    moves.map { |coordinate| [coordinate] }
  end

  def once_vertical?(space)
    (space[1].to_i - row.to_i).abs == 1
  end

  def once_horizontal?(space)
    space[0].succ == column || column.succ == space[0]
  end

  def once_diagonal?(space)
    once_horizontal?(space) && once_vertical?(space)
  end

  def same_column?(space)
    space[0] == column
  end

  def same_row?(space)
    space[1] == row
  end
end
