# frozen_string_literal: true

require_relative '../piece'

# This class handles a Knight chesspiece rules.
class Knight < Piece
  def legal?(space)
    to_coordinate = Coordinate.parse(space)
    return false if position == to_coordinate

    (twice_vertical?(to_coordinate) && once_horizontal?(to_coordinate)) ||
      (twice_horizontal?(to_coordinate) && once_vertical?(to_coordinate))
  end

  def split_moves(moves)
    moves.map { |coordinate| [coordinate] }
  end

  def twice_vertical?(coordinate)
    position.up.up.row == coordinate.row || position.down.down.row == coordinate.row
  end

  def once_vertical?(coordinate)
    position.up.row == coordinate.row || position.down.row == coordinate.row
  end

  def twice_horizontal?(coordinate)
    position.right.right.column == coordinate.column || position.left.left.column == coordinate.column
  end

  def once_horizontal?(coordinate)
    position.right.column == coordinate.column || position.left.column == coordinate.column
  end

  def to_fen
    case colour
    when 'white' then 'N'
    when 'black' then 'n'
    end
  end
end
