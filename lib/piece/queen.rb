# frozen_string_literal: true

require_relative '../piece'

# This class handles a Queen chesspiece.
class Queen < Piece
  def legal?(space)
    to_coordinate = Coordinate.parse(space)
    return false if position == to_coordinate

    on_diagonal?(to_coordinate) || (horizontal?(to_coordinate) || vertical?(to_coordinate))
  end

  def split_moves(moves)
    split_horizontal_vertical(moves) + split_into_diagonals(moves)
  end

  def split_into_diagonals(moves)
    diagonals = []
    diagonals << left_up(moves).reverse
    diagonals << left_down(moves).reverse
    diagonals << right_up(moves)
    diagonals << right_down(moves)
    diagonals
  end

  def split_horizontal_vertical(moves)
    horizontal_vertical = []
    horizontal_vertical << up(moves)
    horizontal_vertical << down(moves).reverse
    horizontal_vertical << left(moves).reverse
    horizontal_vertical << right(moves)
    horizontal_vertical
  end

  def left_up(moves)
    moves.select { |coordinate| coordinate.row.to_i > position.row.to_i && coordinate.column.ord < position.column.ord }
  end

  def left_down(moves)
    moves.select { |coordinate| coordinate.row.to_i < position.row.to_i && coordinate.column.ord < position.column.ord }
  end

  def right_up(moves)
    moves.select { |coordinate| coordinate.row.to_i > position.row.to_i && coordinate.column.ord > position.column.ord }
  end

  def right_down(moves)
    moves.select { |coordinate| coordinate.row.to_i < position.row.to_i && coordinate.column.ord > position.column.ord }
  end

  def up(moves)
    moves.select { |coordinate| coordinate.row.to_i > position.row.to_i && vertical?(coordinate) }
  end

  def down(moves)
    moves.select { |coordinate| coordinate.row.to_i < position.row.to_i && vertical?(coordinate) }
  end

  def left(moves)
    moves.select { |coordinate| coordinate.column.ord < position.column.ord && horizontal?(coordinate) }
  end

  def right(moves)
    moves.select { |coordinate| coordinate.column.ord > position.column.ord && horizontal?(coordinate) }
  end

  def on_diagonal?(space)
    vertical_distance = (space.row.to_i - position.row.to_i).abs
    horizontal_distance = (space.column.ord - position.column.ord).abs
    vertical_distance == horizontal_distance
  end

  def horizontal?(space)
    position.same_row?(space)
  end

  def vertical?(space)
    position.same_column?(space)
  end
end
