# frozen_string_literal: true

require_relative '../piece_navigator'

# This class handles collision for Pawn pieces.
class PawnNavigator < PieceNavigator
  attr_reader :pawn

  def initialize(board, pawn)
    super
    @pawn = pawn
  end

  def possible_moves
    handle_pawn(pawn)
  end

  def handle_pawn(pawn)
    if pawn.colour == 'white'
      handle_white_pawn(pawn)
    else
      handle_black_pawn(pawn)
    end
  end

  def handle_white_pawn(pawn)
    takes = enemy_coordinates(pawn, [pawn.position.left.up, pawn.position.right.up])
    forward = [pawn.position.up, pawn.position.up.up].slice_after do |coordinate|
      board.find(coordinate.to_s).occupied?
    end.first
    forward + takes
  end

  def handle_black_pawn(pawn)
    takes = enemy_coordinates(pawn, [pawn.position.left.down, pawn.position.right.down])
    forward = [pawn.position.down, pawn.position.down.down].slice_after do |coordinate|
      board.find(coordinate.to_s).occupied?
    end.first
    forward + takes
  end
end
