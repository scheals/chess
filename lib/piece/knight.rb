# frozen_string_literal: true

require_relative '../piece'

# This class handles a Knight chesspiece rules.
class Knight < Piece
  def legal?(space)
    to_coordinate = Coordinate.parse(space)
    return false if position == to_coordinate

    (twice_vertical?(to_coordinate) && once_horizontal?(to_coordinate)) || (twice_horizontal?(to_coordinate) && once_vertical?(to_coordinate))
  end

  def split_moves(moves)
    moves.map { |coordinate| [coordinate] }
  end

  def twice_vertical?(coordinate)
    position.row == coordinate.up.up.row || position.row == coordinate.down.down.row
  end

  def once_vertical?(coordinate)
    position.row == coordinate.up.row || position.row == coordinate.down.row
  end

  def twice_horizontal?(coordinate)
    position.column == coordinate.right.right.column || position.column == coordinate.left.left.column
  end

  def once_horizontal?(coordinate)
    position.column == coordinate.right.column || position.column == coordinate.left.column
  end
end
