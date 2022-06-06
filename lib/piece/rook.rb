# frozen_string_literal: true

require_relative '../piece'

# This class handles a Rook chesspiece.
class Rook < Piece
  def legal?(space)
    to_coordinate = Coordinate.parse(space)
    return false if position == to_coordinate

    horizontal?(to_coordinate) || vertical?(to_coordinate)
  end

  def split_moves(moves)
    split_moves = []
    split_moves << up(moves)
    split_moves << down(moves).reverse
    split_moves << left(moves).reverse
    split_moves << right(moves)
    split_moves
  end

  def up(moves)
    moves.select { |coordinate| coordinate.row.to_i > position.row.to_i }
  end

  def down(moves)
    moves.select { |coordinate| coordinate.row.to_i < position.row.to_i }
  end

  def left(moves)
    moves.select { |coordinate| coordinate.column.ord < position.column.ord }
  end

  def right(moves)
    moves.select { |coordinate| coordinate.column.ord > position.column.ord }
  end

  def horizontal?(space)
    position.same_row?(space)
  end

  def vertical?(space)
    position.same_column?(space)
  end
end
