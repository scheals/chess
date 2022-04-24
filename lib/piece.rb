# frozen_string_literal: true

# This class handles abstract chess pieces.
class Piece
  attr_reader :position, :colour

  def initialize(position, colour: nil)
    @position = position
    @colour = colour
  end

  def move(space)
    return nil unless legal?(space)

    @position = space
  end

  def legal?(_space)
    raise 'NotImplemented'
  end

  private

  def column
    position[0]
  end

  def row
    position[1]
  end
end
