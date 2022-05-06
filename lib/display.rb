# frozen_string_literal: true

require 'colorize'

# This module handles a console display.
module Display
  PIECES = { white_king: "\u2654",
             white_queen: "\u2655",
             white_rook: "\u2656",
             white_bishop: "\u2657",
             white_knight: "\u2658",
             white_pawn: "\u2659",
             black_king: "\u265A",
             black_queen: "\u265B",
             black_rook: "\u265C",
             black_bishop: "\u265D",
             black_knight: "\u265E",
             black_pawn: "\u265F",
             _piece: "\u2610" }.freeze
  TILES = { white_tile: ' '.colorize(background: :white),
            black_tile: ' '.colorize(background: :black) }.freeze

  def test
    puts PIECES
    puts TILES
    print PIECES[:white_king].colorize(background: :light_black).white
    print PIECES[:white_king].colorize(background: :light_black).black
    puts PIECES[:black_king].white
    puts PIECES[:black_king].black
  end

  # rubocop: disable Metrics/MethodLength
  def board_test
    4.times do
      puts "\n"
      4.times do
        print PIECES[:white_pawn].colorize(background: :light_black)
        print PIECES[:black_pawn]
      end
      puts "\n"
      4.times do
        print PIECES[:black_pawn]
        print PIECES[:white_pawn].colorize(background: :light_black)
      end
    end
  end
  # rubocop: enable Metrics/MethodLength

  def black_tile(square)
    puts square.colorize(background: :light_black)
  end

  def white_tile(square)
    puts square.colorize(background: :light_black)
  end
end
