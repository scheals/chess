# frozen_string_literal: true

# This class handles a chess board.
class Board
  include Display
  attr_reader :board, :castling_rights

  def initialize(square = Square, factory = PieceFactory)
    @square = square
    @factory = factory
    @board = create_board
    @en_passant_pair = EnPassantPair.new(nil, nil)
    @castling_rights = Hash.new(true)
  end

  def create_board
    board = {}
    ('a'..'h').each do |column_letter|
      column = create_column(column_letter)
      board.merge!(column)
    end
    board
  end

  def setup_from_fen(notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR')
    notation.split('/').each_with_index do |row, row_number|
      fen_numbers(row).each_with_index do |char, column|
        next if char.to_i.positive?

        coordinate = [integer_to_column(column), 8 - row_number].join
        board[coordinate].place(create_fen_piece(char, coordinate))
      end
    end
  end

  def dump_to_fen
    fen = ''
    8.times do |i|
      fen += row(8 - i).values.map { |square| square.piece.to_fen }.join
      fen += '/' unless i == 7
    end
    fen.gsub(/(\d)+/) { |match| match.count('1') }
  end

  def copy
    Marshal.load(Marshal.dump(self))
  end

  def row(number)
    board.select { |key| key.end_with?(number.to_s) }
  end

  def coordinates
    board.keys
  end

  def find(square)
    board[square.to_s]
  end

  def piece_for(square)
    find(square.to_s).piece
  end

  def moves_for(square)
    BoardNavigator.new(self).moves_for(square)
  end

  def pieces
    if block_given?
      pieces = []
      board.values.map(&:piece).select(&:real?).select do |piece|
        pieces << piece if yield(piece)
      end
      return pieces
    end

    board.values.map(&:piece).select(&:real?)
  end

  def find_kings
    pieces{ |piece| piece.instance_of?(King) }
  end

  def king_for(coordinate)
    find_kings.find { |king| piece_for(coordinate).ally?(king) }
  end

  def put(piece, coordinate)
    find(coordinate.to_s).place(piece)
  end

  def move_piece(start, target)
    return nil unless in_bounds?(start) && in_bounds?(target)

    start_square = find(start)
    put(start_square.piece, target)
    start_square.piece.insecure_move(target)
    start_square.vacate
  end

  def vacate(coordinate)
    find(coordinate).vacate
  end

  def in_bounds?(coordinate)
    return true if find(coordinate)

    false
  end

  def create_piece(name, colour:, position:)
    @factory.for(name, colour:, position:)
  end

  def record_en_passant_coordinate
    return en_passant_coordinate.to_s if en_passant_coordinate

    '-'
  end

  def load_en_passant_coordinate(string, colour)
    coordinate = Coordinate.parse(string)
    return if coordinate.to_s == '-'

    @en_passant_pair = EnPassantPair.create_from_coordinate(coordinate, colour, self)
  end

  def create_en_passant_pair(move)
    piece = piece_for(move.target)
    @en_passant_pair = EnPassantPair.create_from_piece(piece)
  end

  def clear_en_passant_pair
    @en_passant_pair = EnPassantPair.new(nil, nil)
  end

  def en_passant_coordinate
    @en_passant_pair&.en_passant_coordinate
  end

  def en_passant
    vacate(@en_passant_pair.piece.position)
  end

  def queenside_castling_rights?(colour)
    return false unless castling_rights["#{colour}_queenside".to_sym]

    colour_pieces = pieces { |piece| piece.colour == colour }
    king = colour_pieces.select { |piece| piece.is_a?(King) }.first
    queenside_rook = colour_pieces.select { |piece| piece.is_a?(Rook) && piece.position.column == 'a' }

    return true if king.can_castle? &&
                   queenside_rook.any?(&:can_castle?)

    false
  end

  def kingside_castling_rights?(colour)
    return false unless castling_rights["#{colour}_kingside".to_sym]

    colour_pieces = pieces { |piece| piece.colour == colour }
    king = colour_pieces.select { |piece| piece.is_a?(King) }.first
    kingside_rook = colour_pieces.select { |piece| piece.is_a?(Rook) && piece.position.column == 'h' }

    return true if king.can_castle? &&
                   kingside_rook.any?(&:can_castle?)

    false
  end

  def record_castling_rights
    castling_rights = []
    colours = %w[white black]

    colours.each do |colour|
      letters = %w[K Q]
      letters.map!(&:downcase) if colour == 'black'
      castling_rights << letters.first if kingside_castling_rights?(colour)
      castling_rights << letters.last if queenside_castling_rights?(colour)
    end

    return '-' if castling_rights.empty?

    castling_rights.join
  end

  def load_castling_rights(string)
    @castling_rights = Hash.new(false)
    @castling_rights[:white_queenside] = true if string.include?('Q')
    @castling_rights[:white_kingside] = true if string.include?('K')
    @castling_rights[:black_queenside] = true if string.include?('q')
    @castling_rights[:black_kingside] = true if string.include?('k')
  end

  def promoteable?(coordinate)
    return true if piece_for(coordinate).promoteable?

    false
  end

  def promote(coordinate, chosen_piece)
    piece_to_promote = piece_for(coordinate)
    promoted_piece = create_piece(chosen_piece, position: coordinate, colour: piece_to_promote.colour)
    put(promoted_piece, piece_to_promote.position)
    promoted_piece
  end

  def win?(current_players_colour)
    BoardNavigator.new(self).win?(current_players_colour)
  end

  def stalemate?(current_player_colour)
    BoardNavigator.new(self).stalemate?(current_player_colour)
  end

  private

  def integer_to_column(integer)
    starting_column = 'a'
    (starting_column.ord + integer).chr
  end

  def create_column(column_letter)
    column = {}
    1.upto(8) do |row_number|
      coordinate = "#{column_letter}#{row_number}"
      column[coordinate] = create_square(coordinate)
    end
    column
  end

  def fen_numbers(row)
    row.gsub(/\d/) { |match| '1'.rjust(match.to_i, '1') }.chars
  end

  def create_square(coordinate)
    @square.new(coordinate)
  end

  def create_fen_piece(name, position)
    @factory.fen_for(name, position)
  end
end
