# frozen_string_literal: true

# This class stores start and end of a move.
class Move
  attr_reader :start, :target

  def initialize(start, target = nil)
    @start = start
    @target = target
  end

  def self.parse(coordinate)
    return coordinate if coordinate.is_a?(Move)

    case coordinate.length
    when 4
      Move.new(coordinate.chars.first(2).join, coordinate.chars.last(2).join)
    when 2
      Move.new(coordinate.chars.first(2).join)
    end
  end

  def full_move?
    return true if start && target

    false
  end

  def partial_move?
    return true if target.nil?

    false
  end
end
