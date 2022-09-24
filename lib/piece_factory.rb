# frozen_string_literal: true

# This module handles creation of particular chess pieces.
module PieceFactory
  PIECES = { 'pawn' => Pawn,
             'rook' => Rook,
             'knight' => Knight,
             'bishop' => Bishop,
             'queen' => Queen,
             'king' => King }.freeze
  FEN = { 'p' => Pawn,
          'r' => Rook,
          'n' => Knight,
          'b' => Bishop,
          'q' => Queen,
          'k' => King }.freeze

  def self.for(name, colour: nil, position: nil)
    (PIECES[name.to_s.downcase] || NilPiece).new(position, colour:)
  end

  def self.fen_for(name, position)
    colour = if name == name.upcase
               'white'
             else
               'black'
             end
    (FEN[name.downcase] || NilPiece).new(position, colour:)
  end
end
