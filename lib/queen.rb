# frozen_string_literal: true

require_relative 'piece'

# This class handles a Queen chesspiece.
class Queen < Piece
  attr_reader :position

  def legal?(space)
    return false if space == position
    
    true
  end
end
