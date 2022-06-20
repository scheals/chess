# frozen_string_literal: true

require_relative '../piece_navigator'
require_relative '../moves'

# This class handles collision for Queen pieces.
class QueenNavigator < PieceNavigator
  attr_reader :piece

  include Moves::HorizontalMoves
  include Moves::DiagonalMoves

  def possible_moves
    horizontal_moves + diagonal_moves
  end
end
