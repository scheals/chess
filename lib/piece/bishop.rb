# frozen_string_literal: true

require_relative '../piece'

# This class handles a Bishop chesspiece
class Bishop < Piece
  def legal?(space)
    to_coordinate = Coordinate.parse(space)
    return false if position == to_coordinate

    on_diagonal?(to_coordinate)
  end

  def split_moves(moves)
    coordinates = moves.map { |move| Coordinate.parse(move) }
    split_moves = []
    split_moves << left_up(coordinates).reverse
    split_moves << left_down(coordinates).reverse
    split_moves << right_up(coordinates)
    split_moves << right_down(coordinates)
    split_moves
  end

  def left_up(coordinates)
    coordinates.select { |coordinate| coordinate.row.to_i > position.row.to_i && coordinate.column.ord < position.column.ord }
  end

  def left_down(coordinates)
    coordinates.select { |coordinate| coordinate.row.to_i < position.row.to_i && coordinate.column.ord < position.column.ord }
  end

  def right_up(coordinates)
    coordinates.select { |coordinate| coordinate.row.to_i > position.row.to_i && coordinate.column.ord > position.column.ord }
  end

  def right_down(coordinates)
    coordinates.select { |coordinate| coordinate.row.to_i < position.row.to_i && coordinate.column.ord > position.column.ord }
  end

  def on_diagonal?(space)
    vertical_distance = (space.row.to_i - position.row.to_i).abs
    horizontal_distance = (space.column.ord - position.column.ord).abs
    vertical_distance == horizontal_distance
  end
end
