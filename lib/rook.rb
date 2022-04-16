# frozen_string_literal: true

# This class handles a rook chesspiece.
class Rook
  attr_reader :position

  def initialize(position)
    @position = position
  end

  def move(space)
    return nil unless legal?(space)

    @position = space
  end

  def legal?(space)
    return false if space == position

    if space[0] == column
      true
    else
      space[1] == row
    end
  end

  private

  def column
    position[0]
  end

  def row
    position[1]
  end
end
