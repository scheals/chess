# frozen_string_literal: true

require_relative '../piece_navigator'
require_relative '../moves'

# This class handles collision for Knight pieces.
class KnightNavigator < PieceNavigator
  attr_reader :piece

  include Moves::CollisionlessMoves

  def possible_moves
    collisionless_moves
  end
end
