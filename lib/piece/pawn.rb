# frozen_string_literal: true

require_relative '../piece'

# This class handles a Pawn chesspiece rules.
class Pawn < Piece
  def legal?(space)
    to_coordinate = Coordinate.parse(space)
    return false if position == to_coordinate

    once_diagonal?(to_coordinate) || (once_vertical?(to_coordinate) && position.same_column?(to_coordinate)) || (double_vertical?(to_coordinate) && position.same_column?(to_coordinate))
  end

  def split_moves(moves)
    coordinates = moves.map { |move| Coordinate.parse(move) }
    split_moves = {}
    split_moves[:up] = up(coordinates) if colour == 'white'
    split_moves[:down] = down(coordinates).reverse if colour == 'black'
    split_moves[:left] = left(coordinates).reverse
    split_moves[:right] = right(coordinates)
    split_moves
  end

  def up(coordinates)
    coordinates.select { |coordinate| coordinate.row.to_i > position.row.to_i && same_column?(coordinate) }
  end

  def down(coordinates)
    coordinates.select { |coordinate| coordinate.row.to_i < position.row.to_i && same_column?(coordinate) }
  end

  def left(coordinates)
    coordinates.select { |coordinate| coordinate.column.ord < position.column.ord }
  end

  def right(coordinates)
    coordinates.select { |coordinate| coordinate.column.ord > position.column.ord }
  end

  def handle_collision(coordinates)
    case colour
    when 'white'
      handle_white_pawn(coordinates)
    when 'black'
      handle_black_pawn(coordinates)
    end
  end

  def handle_white_pawn(coordinates)
    takes = (left(coordinates) + right(coordinates)).select { |coordinate| coordinate.end_with?('E') }
    forward = up(coordinates).reject { |coordinate| coordinate.end_with?('E') }
    [forward, takes]
  end

  def handle_black_pawn(coordinates)
    takes = (left(coordinates) + right(coordinates)).select { |coordinate| coordinate.end_with?('E') }
    forward = down(coordinates).reject { |coordinate| coordinate.end_with?('E') }
    [forward, takes]
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
    position.down.down.row == space.row
  end

  def white_double?(space)
    position.up.up.row == space.row
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
    position.down.row == space.row
  end

  def white_vertical?(space)
    position.up.row == space.row
  end

  def once_horizontal?(space)
    position.left.column == space.column || position.right.column == space.column
  end

  def same_column?(space)
    position.same_column?(space)
  end

  def same_row?(space)
    position.same_row?(space)
  end
end
