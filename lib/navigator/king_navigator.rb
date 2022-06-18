# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for King pieces.
class KingNavigator < PieceNavigator
  attr_reader :piece

  def possible_moves
    moves_without_collision = legal_for(piece)
    moves_without_collision.reject { |move| allied_coordinates(moves_without_collision).include?(move) }
  end
end
