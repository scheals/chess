# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Pawn pieces.
class PawnNavigator < PieceNavigator
  attr_reader :piece

  def possible_moves
    handle_pawn
  end

  def handle_pawn
    if piece.colour == 'white'
      handle_white_pawn
    else
      handle_black_pawn
    end
  end

  def handle_white_pawn
    takes = enemy_coordinates([piece.position.left.up, piece.position.right.up])
    forward = [piece.position.up, piece.position.up.up].slice_after do |coordinate|
      board.find(coordinate.to_s).occupied?
    end.first
    forward + takes
  end

  def handle_black_pawn
    takes = enemy_coordinates([piece.position.left.down, piece.position.right.down])
    forward = [piece.position.down, piece.position.down.down].slice_after do |coordinate|
      board.find(coordinate.to_s).occupied?
    end.first
    forward + takes
  end
end
