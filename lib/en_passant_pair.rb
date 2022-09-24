# frozen_string_literal: true

# Class that holds Piece that can be taken if a move on the en passant coordinate is made by a Pawn.
class EnPassantPair
  attr_reader :piece, :en_passant_coordinate

  def initialize(piece, coordinate)
    @piece = piece
    @en_passant_coordinate = coordinate
  end

  def self.create_from_piece(piece)
    case piece.colour
    when 'white' then coordinate = piece.position.down
    when 'black' then coordinate = piece.position.up
    end
    new(piece, coordinate)
  end

  def self.create_from_coordinate(coordinate, colour, board)
    return new(nil, nil) if coordinate.to_s == '-'

    case colour
    when 'white' then piece = board.piece_for(coordinate.up)
    when 'black' then piece = board.piece_for(coordinate.down)
    end
    new(piece, coordinate)
  end
end
