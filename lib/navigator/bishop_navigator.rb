# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Bishop pieces.
class BishopNavigator < PieceNavigator
  attr_reader :bishop

  def initialize(board, bishop)
    super
    @bishop = bishop
  end

  def possible_moves
    coordinates = legal_for(bishop)
    handle_collision(bishop, bishop.split_moves(coordinates)).compact.flatten
  end
end
