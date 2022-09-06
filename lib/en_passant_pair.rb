# frozen_string_literal: true

# Class that holds Piece that can be taken if a move on the en passant coordinate is made by a Pawn.
class EnPassantPair
  attr_reader :piece, :en_passant_coordinate

  def initialize(piece, coordinate)
    @piece = piece
    @en_passant_coordinate = coordinate
  end
end
