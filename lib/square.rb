# frozen_string_literal: true

require_relative 'piece/nil_piece'

# This class handles a square on a chessboard.
class Square
  attr_reader :position, :piece

  def initialize(position = nil, coordinate: Coordinate)
    @position = coordinate.parse(position)
    @piece = NilPiece.new(position)
  end

  def place(piece)
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
    "#{piece} "
  end
end
