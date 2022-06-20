# frozen_string_literal: true

require_relative '../piece_navigator'
require_relative '../moves'

# This class handles collision for Bishop pieces.
class BishopNavigator < PieceNavigator
  attr_reader :piece

  include Moves::DiagonalMoves

  def possible_moves
    diagonal_moves
  end
end
