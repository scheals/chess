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
end
