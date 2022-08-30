# frozen_string_literal: true

require_relative './player'
require_relative './move'
require_relative './coordinate'

# This class handles a game of Chess.
class Game
  attr_reader :board_navigator, :current_player, :player1, :player2

  def initialize(player1 = Player.new('White', 'white'), player2 = Player.new('Black', 'black'), board_navigator = BoardNavigator.new(Board.new))
    @board_navigator = board_navigator
    @player1 = player1
    @player2 = player2
    @current_player = player1
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
    unvalidated_move = nil
    loop do
      puts "#{current_player.name} as #{current_player.colour} it is your turn!"
      puts 'Enter a full move like \'a8c8\' or a partial move like \'a8\' to see possible moves of that piece.'
      unvalidated_move = Move.parse(gets.chomp.downcase)
      break if correct_length?(unvalidated_move) &&
               in_bounds?(unvalidated_move) &&
               current_player_owns?(unvalidated_move.start)
    end

    validate_target(unvalidated_move)
  end

  def game_loop
    loop do
      puts 'This is how the board looks like:'
      board_navigator.board.show
      move = ask_for_move until move
      board_navigator.board.move_piece(move.start, move.target)
      break if game_over?

      switch_players
    end
    puts "Thanks for playing, #{player1.name} and #{player2.name}!"
  end

  def validate_target(move)
    if legal_target?(move)
      move
    else
      ask_for_target(move)
    end
  end

  def ask_for_target(move)
    possible_moves = board_navigator.moves_for(move.start)
    loop do
      # chess_display.highlight_moves(possible_moves)
      puts 'Those are your possible moves:'
      possible_moves.each { |possible_move| print "#{possible_move} \t" }
      puts "\nWhich one do you want to make? Type 'q' if you want to restart making your move."
      completed_move = Move.new(move.start, gets.chomp.downcase)
      break nil if completed_move.target == 'q'
      break completed_move if legal_target?(completed_move)
    end
  end

  def in_bounds?(move)
    return true if move.in_bounds?(board_navigator.board)

    puts 'Your move is out of bounds.'
    false
  end

  def current_player_owns?(coordinate)
    return true if pick_piece(coordinate)

    puts "You do not own piece at #{coordinate}."
    false
  end

  def legal_target?(move)
    unless move.target
      puts 'Your move lacks a target.'
      return false
    end

    return true if board_navigator.moves_for(move.start).include?(Coordinate.parse(move.target))

    puts 'This move can not be made by this piece.'
    false
  end

  def switch_players
    @current_player = if current_player == @player1
                        @player2
                      else
                        @player1
                      end
  end

  def game_over?
    return true if win?
    # return true if tie?

    false
  end

  def win?
    enemy_king = board_navigator.board.find_kings.find { |king| king.colour != current_player.colour }
    return true if board_navigator.moves_for(enemy_king.position.to_s).empty? && board_navigator.under_check?(enemy_king)

    false
  end

  def correct_length?(move)
    return true if move

    puts 'Your move is either too long or too short in length.'
    false
  end
end
