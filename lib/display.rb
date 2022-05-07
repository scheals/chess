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
  TILES = { white_tile: :white,
            black_tile: :light_black }.freeze
end
