# frozen_string_literal: true

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
