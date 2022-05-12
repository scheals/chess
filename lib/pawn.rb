# frozen_string_literal: true

require_relative 'piece'

# This class handles a Pawn chesspiece rules.
class Pawn < Piece
  def legal?(space)
    return false if space == position

    once_diagonal?(space) || (once_vertical?(space) && same_column?(space)) || (double_vertical?(space) && same_column?(space))
  end

  def double_vertical?(space)
    return false if moved?

    if colour == 'black'
      black_double?(space)
    else
      white_double?(space)
    end
  end

  def black_double?(space)
    (space[1].to_i - row.to_i) == -2
  end

  def white_double?(space)
    (space[1].to_i - row.to_i) == 2
  end

  def once_diagonal?(space)
    once_vertical?(space) && once_horizontal?(space)
  end

  def once_vertical?(space)
    if colour == 'black'
      black_vertical?(space)
    else
      white_vertical?(space)
    end
  end

  def black_vertical?(space)
    (space[1].to_i - row.to_i) == -1
  end

  def white_vertical?(space)
    (space[1].to_i - row.to_i) == 1
  end

  def once_horizontal?(space)
    space[0].succ == column || column.succ == space[0]
  end

  def same_column?(space)
    space[0] == column
  end

  def same_row?(space)
    space[1] == row
  end
end
Pawn.new('b4', colour: 'black').move('c3')
