# frozen_string_literal: true

# This class handles collision for Rook pieces.
class RookNavigator < PieceNavigator
  attr_reader :piece

  include Moves::HorizontalMoves

  def possible_moves
    horizontal_moves
  end
end
