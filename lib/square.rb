# frozen_string_literal: true

require 'colorize'

# This class handles a square on a chessboard.
class Square
  attr_reader :coordinates, :piece

  def initialize(coordinates = nil)
    @coordinates = coordinates
    @piece = nil
  end

  def place(piece)
    return nil if occupied?

    @piece = piece
  end

  def vacate
    return nil unless occupied?

    @piece = nil
  end

  def occupied?
    return true if @piece

    false
  end

  def to_s
    "#{piece.to_s} ".colorize(background: :light_black)
  end
end
