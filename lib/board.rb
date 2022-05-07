# frozen_string_literal: true

require_relative 'square'
require_relative 'piecefactory'
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

  def setup
    setup_rooks
    setup_knights
    setup_bishops
    setup_queens
    setup_kings
    setup_pawns
  end

  def show
    8.times do |i|
      puts row(i + 1).values.join('')
    end
  end

  def setup_rooks
    put(create_piece('rook', colour: 'black', position: 'a8'), 'a8')
    put(create_piece('rook', colour: 'black', position: 'h8'), 'h8')
    put(create_piece('rook', colour: 'white', position: 'a1'), 'a1')
    put(create_piece('rook', colour: 'white', position: 'h1'), 'h1')
  end

  def setup_knights
    put(create_piece('knight', colour: 'black', position: 'b8'), 'b8')
    put(create_piece('knight', colour: 'black', position: 'g8'), 'g8')
    put(create_piece('knight', colour: 'white', position: 'b1'), 'b1')
    put(create_piece('knight', colour: 'white', position: 'g1'), 'g1')
  end

  def setup_bishops
    put(create_piece('bishop', colour: 'black', position: 'c8'), 'c8')
    put(create_piece('bishop', colour: 'black', position: 'f8'), 'f8')
    put(create_piece('bishop', colour: 'white', position: 'c1'), 'c1')
    put(create_piece('bishop', colour: 'white', position: 'f1'), 'f1')
  end

  def setup_queens
    put(create_piece('queen', colour: 'black', position: 'd8'), 'd8')
    put(create_piece('queen', colour: 'white', position: 'd1'), 'd1')
  end

  def setup_kings
    put(create_piece('king', colour: 'black', position: 'e8'), 'e8')
    put(create_piece('king', colour: 'white', position: 'e1'), 'e1')
  end

  def setup_pawns
    row(7).each_value { |square| square.place(create_piece('pawn', colour: 'black', position: square.coordinates)) }
    row(2).each_value { |square| square.place(create_piece('pawn', colour: 'white', position: square.coordinates)) }
  end

  def row(number)
    @board.select { |key| key.end_with?(number.to_s) }
  end

  def put(piece, coordinates)
    find(coordinates).place(piece)
  end

  def find(coordinates)
    @board[coordinates]
  end

  def create_column(number, letter)
    if number.even?
      create_even_column(letter)
    else
      create_odd_column(letter)
    end
  end

  def create_odd_column(letter)
    column = {}
    8.times do |i|
      coordinates = "#{letter}#{i + 1}"
      colour = i.even? ? TILES[:white_tile] : TILES[:black_tile]
      column[coordinates] = create_square(coordinates, colour)
    end
    column
  end

  def create_even_column(letter)
    column = {}
    8.times do |i|
      coordinates = "#{letter}#{i + 1}"
      colour = i.even? ? TILES[:black_tile] : TILES[:white_tile]
      column[coordinates] = create_square(coordinates, colour)
    end
    column
  end

  def create_square(coordinates, colour)
    @square.new(coordinates, colour: colour)
  end

  def create_piece(name, colour:, position:)
    @factory.for(name, colour: colour, position: position)
  end
end
test = Board.new
test.setup
test.show
