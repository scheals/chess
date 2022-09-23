# frozen_string_literal: true

require_relative 'coordinate'

# This class handles abstract chess pieces.
class Piece
  attr_reader :position, :colour, :move_history, :coordinate

  PIECE_REPRESENTATION = { white_king: "\e[1m\u2654",
             white_queen: "\e[1m\u2655",
             white_rook: "\e[1m\u2656",
             white_bishop: "\e[1m\u2657",
             white_knight: "\e[1m\u2658",
             white_pawn: "\e[1m\u2659",
             black_king: "\e[30m\u265A",
             black_queen: "\e[30m\u265B",
             black_rook: "\e[30m\u265C",
             black_bishop: "\e[30m\u265D",
             black_knight: "\e[30m\u265E",
             black_pawn: "\e[30m\u265F",
             _piece: "\u2610" }.freeze

  def initialize(position, colour: nil, coordinate: Coordinate)
    @coordinate = coordinate
    @position = coordinate.parse(position)
    @colour = colour
    @move_history = []
  end

  def move(space)
    return nil unless legal?(space)

    @move_history << space
    @position = coordinate.parse(space)
  end

  def insecure_move(space)
    @move_history << space
    @position = coordinate.parse(space)
  end

  def moved?
    !move_history.empty?
  end

  def legal?(_space)
    raise 'NotImplemented'
  end

  def to_s
    PIECE_REPRESENTATION["#{colour}_#{self.class}".downcase.to_sym]
  end

  def real?
    true
  end

  def legal(coordinates)
    coordinates.select { |coordinate| legal?(coordinate) }
  end

  def split_moves(_moves)
    raise 'NotImplemented'
  end

  def enemy?(piece)
    return true if piece.colour != colour && piece.real?

    false
  end

  def ally?(piece)
    return true if piece.colour == colour

    false
  end

  def ==(other)
    return true if colour == other.colour && position == other.position

    false
  end

  def promoteable?
    false
  end
end
