# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Queen pieces.
class QueenNavigator < PieceNavigator
  attr_reader :queen

  def initialize(board, queen)
    super
    @queen = queen
  end

  def possible_moves
    coordinates = legal_for(queen)
    handle_collision(queen, queen.split_moves(coordinates)).compact.flatten
  end
end
