# frozen_string_literal: true

require_relative 'piece'

# This class handles a Queen chesspiece.
class Queen < Piece
  def legal?(space)
    return false if space == position

    true
  end
end
