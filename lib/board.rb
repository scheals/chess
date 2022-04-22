# frozen_string_literal: true

require_relative 'square'

# This class handles a chess board.
class Board
  def initialize(square = Square)
    @square = square
    @board = create_board
  end

  def create_board
    board = {}
    start_letter = 'a'
    8.times do |i|
      current_letter = start_letter
      i.times do
        current_letter = current_letter.succ
      end
      board.merge!(create_column(current_letter))
    end
    board
  end

  def put(piece, coordinates)
    find(coordinates).place(piece)
  end

  def find(coordinates)
    @board[coordinates]
  end

  def create_column(letter)
    column = {}
    8.times do |i|
      coordinates = "#{letter}#{i + 1}"
      column[coordinates] = create_square(coordinates)
    end
    column
  end

  def create_square(coordinates)
    @square.new(coordinates)
  end
end
