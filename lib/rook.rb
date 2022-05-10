# frozen_string_literal: true

require_relative 'piece'

# This class handles a Rook chesspiece.
class Rook < Piece
  def legal?(space)
    return false if space == position

    horizontal?(space) || vertical?(space)
  end

  def horizontal?(space)
    space[1] == row
  end

  def vertical?(space)
    space[0] == column
  end
end
