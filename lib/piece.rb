# frozen_string_literal: true

# This class handles abstract chess pieces.
class Piece
  attr_reader :position

  def initialize(position)
    @position = position
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
