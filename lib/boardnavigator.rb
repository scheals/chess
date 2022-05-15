# frozen_string_literal: true

require_relative 'board'

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board

  def initialize(board)
    @board = board
  end

  # rubocop: disable all
  def possible_moves(piece)
    case piece.class.to_s
    when 'Knight'
      in_bounds_coordinates(piece) - allied_coordinates(piece)
    when 'King'
      in_bounds_coordinates(piece) - allied_coordinates(piece)
    when 'Rook'
      in_bounds = in_bounds_coordinates(piece)
      occupied = occupied_coordinates(piece)
      allies = allied_coordinates(piece)
      enemies = enemy_coordinates(piece)
      baseline = in_bounds
      upwards = baseline.select { |coordinate| coordinate[1].to_i > piece.position[1].to_i }
      downwards = baseline.select { |coordinate| coordinate[1].to_i < piece.position[1].to_i }
      leftwards = baseline.select { |coordinate| coordinate[0].ord < piece.position[0].ord }
      rightwards = baseline.select { |coordinate| coordinate[0].ord > piece.position[0].ord }

      moves = upwards + downwards + leftwards + rightwards
      possible_up = upwards.map do |coordinate|
        if allies.include?(coordinate)
          next 'ally'
        elsif enemies.include?(coordinate)
          next 'enemy'
        end
        coordinate
      end
      possible_up.drop_while { |coordinate| allies.include?(coordinate) }
    else
      []
    end
  end
# rubocop: enable all

  def in_bounds_coordinates(piece)
    board_coordinates = board.coordinates
    board_coordinates.select { |coordinate| piece.legal?(coordinate) }
  end

  def occupied_coordinates(piece)
    all_coordinates = in_bounds_coordinates(piece)
    all_coordinates.select { |coordinate| board.find(coordinate).occupied? }
  end

  def allied_coordinates(current_piece)
    occupied_coordinates(current_piece).select { |coordinate| current_piece.colour == board.find_piece(coordinate).colour }
  end

  def enemy_coordinates(piece)
    occupied_coordinates(piece) - allied_coordinates(piece)
  end
end
test = BoardNavigator.new(Board.new)
bishop = Bishop.new('e4', colour: 'white')
p test.in_bounds_coordinates(bishop)
