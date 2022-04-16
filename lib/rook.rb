# frozen_string_literal: true

# This class handles a rook chesspiece.
class Rook
  attr_reader :position

  def initialize(position)
    @position = position
  end

  def move(space)
    case space
    when 'a4'
      @position = 'a4'
    when 'b5'
      @position = 'b5'
    end
  end
end
