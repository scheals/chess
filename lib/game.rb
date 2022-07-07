# frozen_string_literal: true

require_relative './player'
require_relative './move'

# This class handles a game of Chess.
class Game
  attr_accessor :current_player
  attr_reader :board_navigator

  def initialize(player1 = Player.new, player2 = Player.new, board_navigator = BoardNavigator.new(Board.new))
    @board_navigator = board_navigator
    @player1 = player1
    @player2 = player2
    @current_player = nil
  end

  def pick_piece(coordinate)
    piece = board_navigator.piece_for(coordinate)
    return nil unless piece.colour == current_player.colour

    piece
  end

  def create_move(coordinate, move_system = Move)
    move_system.parse(coordinate)
  end
end
