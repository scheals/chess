# frozen_string_literal: true

require_relative '../chess'

# This class takes care of loading FEN strings.
class FEN
  attr_reader :fen_string, :board, :current_player_colour, :half_move_clock, :full_move_clock

  def initialize(fen_string)
    convert_string_to_variables(fen_string)
  end

  def convert_string_to_variables(string)
    split_fen = string.split
    @board_pieces = split_fen[0]
    @current_player_colour = decode_player(split_fen[1])
    @castling_rights = split_fen[2]
    @en_passant_coordinate = split_fen[3]
    @half_move_clock = split_fen[4].to_i
    @full_move_clock = split_fen[5].to_i
  end

  def decode_player(letter)
    case letter
    when 'w' then 'white'
    when 'b' then 'black'
    end
  end

  def to_game(white_player, black_player)
    @board = to_board(prevent_pawn_double_move: true)
    Game.new(white_player:, black_player:, board:, current_player_colour:, half_move_clock:, full_move_clock:)
  end

  def to_board(prevent_pawn_double_move: false)
    @board = Board.new
    load_board
    move_pawns if prevent_pawn_double_move
    board
  end

  def load_board
    place_pieces
    load_en_passant_coordinate(@en_passant_coordinate, @current_player_colour)
    load_castling_rights
  end

  def place_pieces
    @board_pieces.split('/').each_with_index do |row, row_number|
      convert_numbers(row).each_with_index do |char, column|
        next if empty_tile?(char)

        coordinate = [integer_to_column(column), 8 - row_number].join
        board.find(coordinate).place(board.create_fen_piece(char, coordinate))
      end
    end
  end

  def load_en_passant_coordinate(string, colour)
    coordinate = Coordinate.parse(string)
    board.en_passant_pair = EnPassantPair.create_from_coordinate(coordinate, colour, board)
  end

  def load_castling_rights
    board.castling_rights = Hash.new(false)
    board.castling_rights[:white_queenside] = true if @castling_rights.include?('Q')
    board.castling_rights[:white_kingside] = true if @castling_rights.include?('K')
    board.castling_rights[:black_queenside] = true if @castling_rights.include?('q')
    board.castling_rights[:black_kingside] = true if @castling_rights.include?('k')
  end

  def move_pawns
    starting_pawn_rows = [2, 7]
    board.pieces do |piece|
      next unless piece.is_a?(Pawn)
      next if starting_pawn_rows.include?(piece.position.row.to_i)

      piece.load_move_history(:no_double_moves)
    end
  end

  def integer_to_column(integer)
    starting_column = 'a'
    (starting_column.ord + integer).chr
  end

  def empty_tile?(fen_character)
    fen_character.to_i.positive?
  end

  def convert_numbers(row)
    row.gsub(/\d/) { |match| '1'.rjust(match.to_i, '1') }.chars
  end
end
