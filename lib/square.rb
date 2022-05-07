# frozen_string_literal: true

require 'colorize'
require_relative 'nilpiece'

# This class handles a square on a chessboard.
class Square
  attr_reader :coordinates, :piece

  def initialize(coordinates = nil, colour: :light_black)
    @coordinates = coordinates
    @piece = NilPiece.new(coordinates)
    @colour = colour
  end

  def place(piece)
    return nil if occupied?

    @piece = piece
  end

  def vacate
    return nil unless occupied?

    @piece = NilPiece.new(coordinates)
  end

  def occupied?
    @piece.real?
  end

  def to_s
    "#{piece.to_s} ".colorize(background: @colour.to_sym)
  end
end
