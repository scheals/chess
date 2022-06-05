# frozen_string_literal: true

require_relative '../piece'

# This class handles a Knight chesspiece rules.
class Knight < Piece
  def legal?(space)
    to_coordinate = Coordinate.parse(space)
    current_coordinate = Coordinate.parse(position)
    return false if current_coordinate == to_coordinate

    (twice_vertical?(to_coordinate) && once_horizontal?(to_coordinate)) || (twice_horizontal?(to_coordinate) && once_vertical?(to_coordinate))
  end

  def split_moves(moves)
    moves.map { |coordinate| [coordinate] }
  end

  def twice_vertical?(coordinate)
    row == coordinate.up.up.row || row == coordinate.down.down.row
  end

  def once_vertical?(coordinate)
    row == coordinate.up.row || row == coordinate.down.row
  end

  def twice_horizontal?(coordinate)
    coordinate.right.right.column == column || coordinate.left.left.column == column
  end

  def once_horizontal?(coordinate)
    coordinate.right.column == column || coordinate.left.column == column
  end
end
