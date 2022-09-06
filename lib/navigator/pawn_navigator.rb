# frozen_string_literal: true

require_relative '../piece_navigator'
require_relative '../moves'

# This class handles collision for Pawn pieces.
class PawnNavigator < PieceNavigator
  attr_reader :piece

  include Moves::PawnForward
  include Moves::PawnTakes

  def possible_moves
    handle_pawn
  end

  def handle_pawn
    if piece.colour == 'white'
      white_forward + white_takes
    else
      black_forward + black_takes
    end
  end

  def en_passant
    en_passant_coordinate = @board_navigator.en_passant_coordinate
    move = []
    if piece.colour == 'white'
      return move << en_passant_coordinate if en_passant_coordinate == piece.position.up.left || en_passant_coordinate == piece.position.up.right

      move
    else
      return move << en_passant_coordinate if en_passant_coordinate == piece.position.down.left || en_passant_coordinate == piece.position.down.right

      move
    end
  end
end
