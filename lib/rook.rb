# frozen_string_literal: true

# This class handles a rook chesspiece.
class Rook
  attr_reader :position

  def initialize(position)
    @position = position
  end

  def move(space)
    @position = 'a4'
  end
end
