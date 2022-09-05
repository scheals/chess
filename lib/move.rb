# frozen_string_literal: true

require_relative 'coordinate'

# This class stores start and end of a move.
class Move
  attr_reader :start, :target

  def initialize(start, target = nil)
    @start = Coordinate.parse(start)
    @target = Coordinate.parse(target) if target
  end

  def self.parse(move)
    return move if move.is_a?(Move)

    case move.length
    when 4
      Move.new(move.chars.first(2).join, move.chars.last(2).join)
    when 2
      Move.new(move.chars.first(2).join)
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

  def in_bounds?(board)
    return board.in_bounds?(start) && board.in_bounds?(target) if full_move?
    return board.in_bounds?(start) if partial_move?
  end

  def ==(other)
    start == other.start && target == other.target
  end

  def to_s
    [start, target].map(&:to_s).join
  end
end
