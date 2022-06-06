# frozen_string_literal: true

require_relative '../piece'

# This class handles a King chesspiece.
class King < Piece
  def legal?(space)
    to_coordinate = Coordinate.parse(space)
    return false if position == to_coordinate

    once_diagonal?(to_coordinate) || (once_horizontal?(to_coordinate) && position.same_row?(to_coordinate)) || (once_vertical?(to_coordinate) && position.same_column?(to_coordinate))
  end

  def split_moves(moves)
    moves.map { |coordinate| [coordinate] }
  end

  def once_vertical?(space)
    position.up.row == space.row || position.down.row == space.row
  end

  def once_horizontal?(space)
    position.left.column == space.column || position.right.column == space.column
  end

  def once_diagonal?(space)
    once_horizontal?(space) && once_vertical?(space)
  end
end
