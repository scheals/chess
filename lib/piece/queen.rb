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
    coordinates = moves.map { |move| Coordinate.parse(move) }
    split_horizontal_vertical(coordinates) + split_into_diagonals(coordinates)
  end

  def split_into_diagonals(coordinates)
    diagonals = []
    diagonals << left_up(coordinates).reverse
    diagonals << left_down(coordinates).reverse
    diagonals << right_up(coordinates)
    diagonals << right_down(coordinates)
    diagonals
  end

  def split_horizontal_vertical(coordinates)
    horizontal_vertical = []
    horizontal_vertical << up(coordinates)
    horizontal_vertical << down(coordinates).reverse
    horizontal_vertical << left(coordinates).reverse
    horizontal_vertical << right(coordinates)
    horizontal_vertical
  end

  def left_up(coordinates)
    coordinates.select { |coordinate| position.to_left?(coordinate) && position.to_up?(coordinate) }
  end

  def left_down(coordinates)
    coordinates.select { |coordinate| position.to_left?(coordinate) && position.to_down?(coordinate) }
  end

  def right_up(coordinates)
    coordinates.select { |coordinate| position.to_right?(coordinate) && position.to_up?(coordinate) }
  end

  def right_down(coordinates)
    coordinates.select { |coordinate| position.to_right?(coordinate) && position.to_down?(coordinate) }
  end

  def up(coordinates)
    coordinates.select { |coordinate| position.to_up?(coordinate) && vertical?(coordinate) }
  end

  def down(coordinates)
    coordinates.select { |coordinate| position.to_down?(coordinate) && vertical?(coordinate) }
  end

  def left(coordinates)
    coordinates.select { |coordinate| position.to_left?(coordinate) && horizontal?(coordinate) }
  end

  def right(coordinates)
    coordinates.select { |coordinate| position.to_right?(coordinate) && horizontal?(coordinate) }
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
