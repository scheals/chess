# frozen_string_literal: true

require_relative 'piece_factory'

# This is a class that holds a move together with the piece that made it and
# information on whether it was a capture.
class PieceMove
  attr_reader :piece, :move, :capture

  def initialize(piece, move, capture: false)
    @piece = create_piece(piece)
    @move = move
    @capture = capture
  end

  def ==(other)
    piece == other.piece && move == other.move
  end

  def create_piece(piece)
    PieceFactory.piece_for(piece.class, position: piece.position, colour: piece.colour)
  end
end
