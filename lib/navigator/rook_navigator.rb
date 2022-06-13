# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Rook pieces.
class RookNavigator < PieceNavigator
  attr_reader :rook

  def initialize(board, rook)
    super
    @rook = rook
  end

  def possible_moves
    coordinates = legal_for(rook)
    handle_collision(rook, rook.split_moves(coordinates)).compact.flatten
  end
end
