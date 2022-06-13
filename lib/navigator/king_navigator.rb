# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for King pieces.
class KingNavigator < PieceNavigator
  attr_reader :king
  
  def initialize(board, king)
    super
    @king = king
  end

  def possible_moves
    coordinates = legal_for(king)
    handle_collision(king, king.split_moves(coordinates)).compact.flatten
  end
end
