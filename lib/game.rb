# frozen_string_literal: true

require_relative './player'
require_relative './move'
require_relative './coordinate'

# rubocop: disable Metrics/ClassLength
# This class handles a game of Chess.
class Game
  attr_reader :board_navigator, :current_player, :player1, :player2

  def initialize(player1 = Player.new('White', 'white'),
                 player2 = Player.new('Black', 'black'),
                 board_navigator = BoardNavigator.new(Board.new))
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
      unvalidated_move = create_move(gets.chomp.downcase)
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
      board_navigator.move_piece(move.start, move.target)
      promote(move.target) if promoteable?(move.target)
      castle(move) if castling?(move)
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

  def promote(coordinate)
    chosen_piece = ask_for_promotion until chosen_piece
    board_navigator.promote(coordinate, chosen_piece)
  end

  def promoteable?(coordinate)
    return true if board_navigator.promoteable?(coordinate)

    false
  end

  def ask_for_promotion
    pieces = { 'r' => 'rook',
               'n' => 'knight',
               'b' => 'bishop',
               'q' => 'queen',
               'rook' => 'rook',
               'knight' => 'knight',
               'bishop' => 'bishop',
               'queen' => 'queen' }
    puts "#{current_player.name} promote your Pawn! FEN and full names accepted."
    player_input = gets.chomp.downcase
    unless pieces[player_input]
      puts 'Incorrect input!'
      return nil
    end

    pieces[player_input]
  end

  def castling?(move)
    castling_moves = %w[e1c1 e8c8 e1g1 e8g8]
    return true if board_navigator.piece_for(move.target).is_a?(King) && castling_moves.include?(move.to_s)

    false
  end

  def castle(move)
    case move.to_s
    when 'e1c1' then board_navigator.move_piece('a1', 'd1')
    when 'e8c8' then board_navigator.move_piece('a8', 'd8')
    when 'e1g1' then board_navigator.move_piece('h1', 'f1')
    when 'e8g8' then board_navigator.move_piece('h8', 'f8')
    end
  end

  def en_passant_opportunity?(move)
    return true if board_navigator.piece_for(move.target).is_a?(Pawn) &&
                   (move.start[1].to_i - move.target[1].to_i).abs == 2

    false
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
    @current_player = if current_player == player1
                        player2
                      else
                        player1
                      end
  end

  def game_over?
    return true if win?
    # return true if tie?

    false
  end

  def win?
    return true if board_navigator.win?(current_player.colour)

    false
  end

  def correct_length?(move)
    return true if move

    puts 'Your move is either too long or too short in length.'
    false
  end
end
# rubocop: enable Metrics/ClassLength
