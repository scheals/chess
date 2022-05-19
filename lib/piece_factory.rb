# frozen_string_literal: true

require_relative 'piece'
require_relative 'piece/pawn'
require_relative 'piece/rook'
require_relative 'piece/knight'
require_relative 'piece/bishop'
require_relative 'piece/queen'
require_relative 'piece/king'

# This module handles creation of particular chess pieces.
module PieceFactory
  PIECES = { 'pawn' => Pawn,
             'rook' => Rook,
             'knight' => Knight,
             'bishop' => Bishop,
             'queen' => Queen,
             'king' => King }.freeze

  def self.for(name, colour: nil, position: nil)
    (PIECES[name.to_s.downcase] || Piece).new(position, colour: colour)
  end
end
