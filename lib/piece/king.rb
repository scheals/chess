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
    position.row == space.up.row || position.row == space.down.row
  end

  def once_horizontal?(space)
    position.column == space.left.column || position.column == space.right.column
  end

  def once_diagonal?(space)
    once_horizontal?(space) && once_vertical?(space)
  end
end
