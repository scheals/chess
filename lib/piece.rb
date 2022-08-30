# frozen_string_literal: true

require_relative 'display'
require_relative 'coordinate'

# This class handles abstract chess pieces.
class Piece
  include Display
  attr_reader :position, :colour, :move_history, :coordinate

  def initialize(position, colour: nil, coordinate: Coordinate)
    @coordinate = coordinate
    @position = coordinate.parse(position)
    @colour = colour
    @move_history = []
  end

  def move(space)
    return nil unless legal?(space)

    @move_history << space
    @position = coordinate.parse(space)
  end

  def insecure_move(space)
    @move_history << space
    @position = coordinate.parse(space)
  end

  def moved?
    !move_history.empty?
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

  def legal(coordinates)
    coordinates.select { |coordinate| legal?(coordinate) }
  end

  def split_moves(_moves)
    raise 'NotImplemented'
  end

  def enemy?(piece)
    return true if piece.colour != colour && piece.real?

    false
  end

  def ally?(piece)
    return true if piece.colour == colour

    false
  end

  def ==(other)
    return true if colour == other.colour && position == other.position && move_history == other.move_history

    false
  end

  def promoteable?
    false
  end
  
  private

  def column
    position[0]
  end

  def row
    position[1]
  end
end
