# frozen_string_literal: true

require_relative 'display'

# This class handles abstract chess pieces.
class Piece
  include Display
  attr_reader :position, :colour, :move_history

  def initialize(position, colour: nil)
    @position = position
    @colour = colour
    @move_history = []
  end

  def move(space)
    return nil unless legal?(space)

    @move_history << space
    @position = space
  end

  def legal?(_space)
    raise 'NotImplemented'
  end

  def to_s
    PIECES["#{colour}_#{self.class}".downcase.to_sym]
  end

  def real?
    true
  end

  private

  def column
    position[0]
  end

  def row
    position[1]
  end
end
