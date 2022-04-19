# frozen_string_literal: true

require_relative 'piece'

# This class handles a rook chesspiece.
class Rook < Piece
  def legal?(space)
    return false if space == position

    if space[0] == column
      true
    else
      space[1] == row
    end
  end
end
