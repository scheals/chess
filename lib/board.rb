# frozen_string_literal: true

require_relative 'square'
require_relative 'piece_factory'
require_relative 'display'
require 'colorize'

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
    start_letter = 'a'
    8.times do |i|
      current_letter = (start_letter.ord + i).chr
      column = create_column(i, current_letter)
      board.merge!(column)
    end
    board
  end

  def setup(notation = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR')
    notation.split('/').each_with_index do |row, row_number|
      fen_numbers(row).each_with_index do |char, column|
        next if char.to_i.positive?

        coordinate = [integer_to_column(column), 8 - row_number].join
        board[coordinate].place(create_fen_piece(char, coordinate))
      end
    end
  end

  def fen_numbers(row)
    row.gsub(/\d/) { |match| '1'.rjust(match.to_i, '1') }.chars
  end

  def dump_to_fen
    fen = ''
    8.times do |i|
      fen += row(8 - i).values.map { |square| square.piece.to_fen }.join
      fen += '/'
    end
    fen
  end

  def copy
    Marshal.load(Marshal.dump(self))
  end

  def show
    8.times do |i|
      print(8 - i)
      puts row(8 - i).values.join
    end
    puts "\s\sa\sb\sc\sd\se\sf\sg\sh"
  end

  def row(number)
    @board.select { |key| key.end_with?(number.to_s) }
  end

  def coordinates
    board.keys
  end

  def find(square)
    @board[square]
  end

  def find_piece(square)
    find(square).piece
  end

  def find_kings
    board.values.map(&:piece).select { |piece| piece.instance_of?(King) }
  end

  def put(piece, coordinate)
    find(coordinate).place(piece)
  end

  def move_piece(start, target)
    return nil unless in_bounds?(start) && in_bounds?(target)

    start_square = find(start)
    put(start_square.piece, target)
    start_square.piece.insecure_move(target)
    start_square.vacate
  end

  def in_bounds?(coordinate)
    return true if find(coordinate)

    false
  end

  def create_column(number, letter)
    if number.even?
      create_even_column(letter)
    else
      create_odd_column(letter)
    end
  end

  def create_square(coordinate, colour)
    @square.new(coordinate, colour:)
  end

  def create_piece(name, colour:, position:)
    @factory.for(name, colour:, position:)
  end

  def create_fen_piece(name, position)
    @factory.fen_for(name, position)
  end

  private

  def create_odd_column(letter)
    column = {}
    8.times do |i|
      coordinate = "#{letter}#{i + 1}"
      colour = i.even? ? TILES[:white_tile] : TILES[:black_tile]
      column[coordinate] = create_square(coordinate, colour)
    end
    column
  end

  def create_even_column(letter)
    column = {}
    8.times do |i|
      coordinate = "#{letter}#{i + 1}"
      colour = i.even? ? TILES[:black_tile] : TILES[:white_tile]
      column[coordinate] = create_square(coordinate, colour)
    end
    column
  end

  def integer_to_column(integer)
    column = 'a'
    integer.times do
      column = column.succ
    end
    column
  end
end
