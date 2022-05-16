# frozen_string_literal: true

require_relative 'piece'

# This class handles a Queen chesspiece.
class Queen < Piece
  def legal?(space)
    return false if space == position

    on_diagonal?(space) || (horizontal?(space) || vertical?(space))
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
    moves.select { |coordinate| coordinate[1].to_i > position[1].to_i && coordinate[0].ord < position[0].ord }
  end

  def left_down(moves)
    moves.select { |coordinate| coordinate[1].to_i < position[1].to_i && coordinate[0].ord < position[0].ord }
  end

  def right_up(moves)
    moves.select { |coordinate| coordinate[1].to_i > position[1].to_i && coordinate[0].ord > position[0].ord }
  end

  def right_down(moves)
    moves.select { |coordinate| coordinate[1].to_i < position[1].to_i && coordinate[0].ord > position[0].ord }
  end

  def up(moves)
    moves.select { |coordinate| coordinate[1].to_i > position[1].to_i && vertical?(coordinate) }
  end

  def down(moves)
    moves.select { |coordinate| coordinate[1].to_i < position[1].to_i && vertical?(coordinate) }
  end

  def left(moves)
    moves.select { |coordinate| coordinate[0].ord < position[0].ord && horizontal?(coordinate) }
  end

  def right(moves)
    moves.select { |coordinate| coordinate[0].ord > position[0].ord && horizontal?(coordinate) }
  end

  def on_diagonal?(space)
    vertical_distance = (space[1].to_i - row.to_i).abs
    horizontal_distance = (space[0].ord - column.ord).abs
    vertical_distance == horizontal_distance
  end

  def horizontal?(space)
    space[1] == row
  end

  def vertical?(space)
    space[0] == column
  end
end
