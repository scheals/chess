# frozen_string_literal: true

# This class handles collision rules for Pieces
class PieceNavigator
  attr_reader :board, :piece

  def initialize(board_navigator, piece)
    @board = board_navigator.board
    @piece = piece
  end

  def possible_moves
    raise 'NotImplemented'
  end

  def legal_for(piece)
    piece.legal(board.coordinates)
  end

  def allied_coordinates(coordinates)
    coordinates.select { |coordinate| piece.ally?(board.piece_for(coordinate)) }
  end

  def enemy_coordinates(coordinates)
    coordinates.select { |coordinate| piece.enemy?(board.piece_for(coordinate)) }
  end

  def empty_or_enemy?(square)
    !square.occupied? || piece.enemy?(square.piece)
  end

  def passable?(move, square)
    board.in_bounds?(move) && !square.occupied?
  end
end
