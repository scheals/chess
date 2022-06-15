# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Queen pieces.
class QueenNavigator < PieceNavigator
  attr_reader :piece

  def possible_moves
    coordinates = legal_for(piece)
    handle_collision(piece.split_moves(coordinates)).compact.flatten
  end
end
