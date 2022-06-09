# frozen_string_literal: true

require 'colorize'
require_relative 'piece/nil_piece'

# This class handles a square on a chessboard.
class Square
  attr_reader :position, :piece

  def initialize(position = nil, colour: nil, coordinate: Coordinate)
    @position = coordinate.parse(position)
    @piece = NilPiece.new(position)
    @colour = colour
  end

  def place(piece)
    return nil if occupied?

    @piece = piece
  end

  def vacate
    return nil unless occupied?

    @piece = NilPiece.new(position)
  end

  def occupied?
    @piece.real?
  end

  def to_s
    "#{piece} ".colorize(background: @colour.to_sym)
  end
end
