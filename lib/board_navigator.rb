# frozen_string_literal: true

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board, :navigator_factory, :coordinate_system

  def initialize(board, navigator_factory = NavigatorFactory, coordinate_system = Coordinate)
    @board = board
    @navigator_factory = navigator_factory
    @coordinate_system = coordinate_system
  end

  def moves_after_collision_for(coordinate)
    return nil unless board.piece_for(coordinate)

    navigator = navigator_factory.for(board, board.piece_for(coordinate))
    navigator.possible_moves.map { |move| coordinate_system.parse(move) }
  end

  def moves_for(coordinate)
    moves_after_collision_for(coordinate).reject { |move| move_checks_own_king?(coordinate, move.to_s) }
  end

  def under_check?(king)
    king_navigator = if king.instance_of?(KingNavigator)
                       king
                     else
                       navigator_factory.for(board, king)
                     end

    return true if enemy_moves(king_navigator).any? { |moves| moves.include?(king_navigator.piece.position) }

    false
  end

  def move_checks_own_king?(start, target)
    board_after_move = BoardNavigator.new(board.copy, navigator_factory)
    board_after_move.board.move_piece(start, target)
    board_after_move.under_check?(board_after_move.board.king_for(target))
  end

  def enemy_moves(piece_navigator)
    piece_navigator.enemy_coordinates(board.coordinates).map { |coordinate| moves_after_collision_for(coordinate) }
  end

  def win?(current_players_colour)
    enemy_king = board.find_kings.find { |king| king.colour != current_players_colour }
    return true if moves_for(enemy_king.position.to_s).empty? && under_check?(enemy_king)

    false
  end

  def stalemate?(current_players_colour)
    enemy_pieces = board.pieces.reject { |piece| piece.colour == current_players_colour }
    return true if enemy_pieces.map { |piece| moves_for(piece.position.to_s) }.all?(&:empty?) &&
                   !under_check?(enemy_pieces.find { |piece| piece.is_a?(King) })

    false
  end
end
