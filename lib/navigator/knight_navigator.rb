# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Knight pieces.
class KnightNavigator < PieceNavigator
  attr_reader :knight

  def initialize(board, knight)
    super
    @knight = knight
  end

  def possible_moves
    coordinates = legal_for(knight)
    handle_collision(knight, knight.split_moves(coordinates)).compact.flatten
  end
end
