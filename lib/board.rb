# frozen_string_literal: true

require_relative 'square'
require_relative 'piece_factory'
require_relative 'display'

# This class handles a chess board.
class Board
  include Display
  attr_reader :board

  def initialize(square = Square, factory = PieceFactory)
    @square = square
    @factory = factory
    @board = create_board
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
    pieces.select { |piece| piece.instance_of?(King) }
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
