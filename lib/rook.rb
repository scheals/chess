# frozen_string_literal: true

require_relative 'piece'

# This class handles a Rook chesspiece.
class Rook < Piece
  def legal?(space)
    return false if space == position

    horizontal?(space) || vertical?(space)
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
    moves.select { |coordinate| coordinate[1].to_i > position[1].to_i }
  end

  def down(moves)
    moves.select { |coordinate| coordinate[1].to_i < position[1].to_i }
  end

  def left(moves)
    moves.select { |coordinate| coordinate[0].ord < position[0].ord }
  end

  def right(moves)
    moves.select { |coordinate| coordinate[0].ord > position[0].ord }
  end

  def horizontal?(space)
    space[1] == row
  end

  def vertical?(space)
    space[0] == column
  end
end
