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

  def ask_for_move
    loop do
      puts 'Where do you want to move? OR where do you want to move from?'
      move = create_move(gets.downcase)
      break if move && move&.in_bounds?(board_navigator.board)

      puts 'Invalid input. Make sure it is valid - either single coordinate like \'a4\' or full move like \'a4b4\'.'
      puts 'It might be out of bounds too, so check that.'
    end
    move
  end

  def complete_move(move)
    possible_moves = board_navigator.moves_for(move.start)
    board.show_possible_moves(possible_moves)
    loop do
      puts 'Where do you want to move?'
      move.target = gets.downcase
      break if move.in_bounds?(board_navigator.board) && valid_move?(possible_moves, move.target)

      puts 'Invalid input. Either out of bounds or not possible for this piece.'
    end
    move
  end

  def round
    board_navigator.board.show
    loop do
      move = ask_for_move
      if move.full_move?
        break if valid_move?(board_navigator.moves_for(move.start), move.target)

      elsif move.partial_move?
        break complete_move(move)
      end
    end
    move
  end
end
