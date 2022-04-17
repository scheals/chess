# frozen_string_literal: true

require_relative 'piece'

# This class handles a Bishop chesspiece
class Bishop < Piece

  def legal?(space)
    return false if space == position

    if space[0] == column || space[1] == row
      false
    else
      true
    end
  end
end
