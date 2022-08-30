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

  def promoteable?
    if piece.colour == 'white'
      %w[a8 b8 c8 d8 e8 f8 g8 h8].include?(piece.position.to_s)
    else
      %w[a1 b1 c1 d1 e1 f1 g1 h1].include?(piece.position.to_s)
    end
  end
end
