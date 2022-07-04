# frozen_string_literal: true

require_relative 'piece_navigator'
require_relative 'navigator/pawn_navigator'
require_relative 'navigator/rook_navigator'
require_relative 'navigator/knight_navigator'
require_relative 'navigator/bishop_navigator'
require_relative 'navigator/queen_navigator'
require_relative 'navigator/king_navigator'

# This module handles creation of particular chess piece navigators
module NavigatorFactory
  PIECES = { 'pawn' => PawnNavigator,
             'rook' => RookNavigator,
             'knight' => KnightNavigator,
             'bishop' => BishopNavigator,
             'queen' => QueenNavigator,
             'king' => KingNavigator }.freeze

  def self.for(board_navigator, piece)
    (PIECES[piece.class.to_s.downcase] || PieceNavigator).new(board_navigator, piece)
  end
end
