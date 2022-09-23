# frozen_string_literal: true

require_relative './player'
require_relative './move'
require_relative './coordinate'
require_relative './save_state'
require_relative './display'

# rubocop: disable Metrics/ClassLength
# This class handles a game of Chess.
class Game
  attr_reader :board_navigator, :current_player, :player1, :player2, :display, :board

  def initialize(player1 = Player.new('White', 'white'),
                 player2 = Player.new('Black', 'black'),
                 board_navigator = BoardNavigator.new(Board.new),
                 display = Display)
    @board_navigator = board_navigator
    @board = board_navigator.board
    @player1 = player1
    @player2 = player2
    @current_player = player1
    @display = display
    @full_move_clock = 1
    @half_move_clock = 0
    @board_state_history = []
  end

  def pick_piece(coordinate)
    piece = board.piece_for(coordinate)
    return nil unless piece.colour == current_player.colour

    piece
  end

  def create_move(coordinate, move_system = Move)
    move_system.parse(coordinate)
  end

  def ask_for_move
    unvalidated_move = nil
    loop do
      unvalidated_move = create_move(gets.chomp.downcase)
      return 'save' if unvalidated_move.to_s == 'save'
      break validate_target(unvalidated_move) if correct_length?(unvalidated_move) &&
                                                 in_bounds?(unvalidated_move) &&
                                                 current_player_owns?(unvalidated_move.start)
    end
  end

  def validate_target(move)
    if legal_target?(move)
      move
    else
      ask_for_target(move)
    end
  end

  def ask_for_target(move)
    possible_moves = board.moves_for(move.start)
    loop do
      puts display.possible_moves(board, possible_moves)
      completed_move = Move.new(move.start, gets.chomp.downcase)
      if completed_move.target.to_s == 'q'
        puts display.turn_beginning(current_player, board)
        break nil
      end
      break completed_move if legal_target?(completed_move)
    end
  end

  def promote(coordinate)
    chosen_piece = ask_for_promotion until chosen_piece
    board.promote(coordinate, chosen_piece)
  end

  def promoteable?(coordinate)
    return true if board.promoteable?(coordinate)

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
    puts display.promotion(current_player)
    player_input = gets.chomp.downcase
    unless pieces[player_input]
      puts display.incorrect_input
      return nil
    end

    pieces[player_input]
  end

  def castling?(move)
    castling_moves = %w[e1c1 e8c8 e1g1 e8g8]
    return true if board.piece_for(move.target).is_a?(King) && castling_moves.include?(move.to_s)

    false
  end

  def castle(move)
    case move.to_s
    when 'e1c1' then board.move_piece('a1', 'd1')
    when 'e8c8' then board.move_piece('a8', 'd8')
    when 'e1g1' then board.move_piece('h1', 'f1')
    when 'e8g8' then board.move_piece('h8', 'f8')
    end
  end

  def handle_en_passant(move)
    en_passant if en_passant?(move)
    board.clear_en_passant_pair
    send_en_passant_opportunity(move) if en_passant_opportunity?(move)
  end

  def en_passant_opportunity?(move)
    return true if board.piece_for(move.target).is_a?(Pawn) &&
                   (move.start.row.to_i - move.target.row.to_i).abs == 2

    false
  end

  def send_en_passant_opportunity(move)
    board.create_en_passant_pair(move)
  end

  def en_passant?(move)
    return true if move.target == board.en_passant_coordinate &&
                   board.piece_for(move.target).is_a?(Pawn)

    false
  end

  def en_passant
    board.en_passant
  end

  def in_bounds?(move)
    return true if move.in_bounds?(board)

    puts display.move_out_of_bounds
    false
  end

  def current_player_owns?(coordinate)
    return true if pick_piece(coordinate)

    puts display.piece_not_owned(coordinate)
    false
  end

  def legal_target?(move)
    unless move.target
      puts display.move_no_target
      return false
    end

    return true if board.moves_for(move.start).include?(Coordinate.parse(move.target))

    puts display.move_impossible_for_piece
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
    return true if win? || tie?

    false
  end

  def win?
    if board.win?(current_player.colour)
      puts display.congratulate(current_player)
      return true
    end

    false
  end

  def tie?
    return true if threefold_repetition? || fifty_move_rule? || stalemate?

    false
  end

  def stalemate?
    if board.stalemate?(current_player.colour)
      puts display.stalemate(player1, player2)
      return true
    end

    false
  end

  def fifty_move_rule?
    if @half_move_clock == 100
      puts display.fifty_moves_tie(player1, player2)
      return true
    end

    false
  end

  def threefold_repetition?
    if @board_state_history.tally.values.any? { |value| value == 3 }
      puts display.threefold_tie(player1, player2)
      return true
    end

    false
  end

  def increment_fullmove_clock
    @full_move_clock += 1
  end

  def calculate_halfmove_clock(move)
    piece = board.piece_for(move.start)
    capture = board.piece_for(move.target).real?
    if piece.is_a?(Pawn) || capture
      @half_move_clock = 0
    else
      @half_move_clock += 1
    end
  end

  def to_fen(full: true)
    result = []
    result << board.dump_to_fen
    result << current_player.colour.chars.first
    result << board.record_castling_rights
    result << board.record_en_passant_coordinate
    result << @half_move_clock if full
    result << @full_move_clock if full
    result.join(' ')
  end

  def save_game
    Dir.mkdir('savegames') unless Dir.exist?('savegames')

    filename = "#{player1.name}-#{player2.name}-#{Time.now}"
    File.open("savegames/#{filename}", 'w') do |file|
      file.puts to_fen
    end
    puts display.save_goodbye(to_fen, filename, player1, player2)
  end

  def load(fen_string)
    save_state = SaveState.new(fen_string)
    game_state = save_state.game_state
    @current_player = load_current_player(game_state[:current_player])
    @half_move_clock = game_state[:half_move_clock]
    @full_move_clock = game_state[:full_move_clock]
    load_board(save_state.board_state, current_player.colour)
  end

  def load_board(state, colour)
    setup_board(state[:board])
    board.load_castling_rights(state[:castling_rights])
    board.load_en_passant_coordinate(state[:en_passant_coordinate], colour)
  end

  def load_current_player(string)
    @current_player = [player1, player2].select { |player| player.colour.chars.first == string }.first
  end

  def setup_board(fen_string)
    board.setup_from_fen(fen_string)
  end

  def correct_length?(move)
    return true if move

    puts display.move_wrong_length
    false
  end

  def move_piece(move)
    board.move_piece(move.start, move.target)
  end

  def store_history
    @board_state_history << to_fen(full: false)
  end

  def black_finished_move?
    return true if current_player.colour == 'black'

    false
  end
end
# rubocop: enable Metrics/ClassLength
