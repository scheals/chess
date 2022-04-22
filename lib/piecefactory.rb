# frozen_string_literal: true

require_relative 'pawn'
require_relative 'rook'
require_relative 'knight'
require_relative 'bishop'
require_relative 'queen'
require_relative 'king'

# This module handles creation of particular chess pieces.
module PieceFactory
  PIECES = { 'pawn' => Pawn,
             'rook' => Rook,
             'knight' => Knight,
             'bishop' => Bishop,
             'queen' => Queen,
             'king' => King }.freeze

  def self.for(name, position = nil)
    (PIECES[name.to_s.downcase] || Piece).new(position)
  end
end
