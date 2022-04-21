# frozen_string_literal: true

require_relative 'square'

# This class handles a chess board.
class Board
  def initialize(square = Square.new)
    @square = square
    @board = create_board
  end

  def create_board
    board = []
    start_letter = 'a'
    8.times do |i|
      current_letter = start_letter
      i.times do
        current_letter = current_letter.succ
      end
      board << create_column(current_letter)
    end
    board
  end

  def create_column(letter)
    row = []
    8.times do |i|
      row << Square.new("#{letter}#{i + 1}")
    end
    row
  end
end
