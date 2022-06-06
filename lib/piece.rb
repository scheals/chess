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

  def handle_collision(moves)
    split_moves(moves).map { |direction| handle_allies(direction) }.map { |direction| handle_enemies(direction) }
  end

  def handle_enemies(direction)
    direction.slice_after { |coordinate| coordinate.end_with?('E') }.first
  end

  def handle_allies(direction)
    direction.take_while { |coordinate| !coordinate.end_with?('A') }
  end

  def split_moves(_moves)
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
