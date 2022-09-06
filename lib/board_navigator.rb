# frozen_string_literal: true

require_relative 'navigator_factory'
require_relative 'en_passant_pair'

# This class handles movement logic for a chessboard.
class BoardNavigator
  attr_reader :board, :navigator_factory, :coordinate_system

  def initialize(board, navigator_factory = NavigatorFactory, coordinate_system = Coordinate)
    @board = board
    @navigator_factory = navigator_factory
    @coordinate_system = coordinate_system
    @en_passant_pair = nil
  end

  def moves_after_collision_for(coordinate)
    return nil unless piece_for(coordinate)

    navigator = navigator_factory.for(self, piece_for(coordinate))
    navigator.possible_moves
  end

  def moves_for(coordinate)
    moves_after_collision_for(coordinate).reject { |move| checks_king?(coordinate, move.to_s) }.map { |move| Coordinate.parse(move) }
  end

  def piece_for(coordinate)
    board.find_piece(coordinate)
  end

  def king_for(coordinate)
    board.find_kings.select { |king| board.find_piece(coordinate).ally?(king) }.first
  end

  def under_check?(king)
    king_navigator = if king.instance_of?(KingNavigator)
                       king
                     else
                       navigator_factory.for(self, king)
                     end

    return true if enemy_moves(king_navigator).any? { |moves| moves.include?(king_navigator.piece.position) }

    false
  end

  def checks_king?(start, target)
    board_after_move = BoardNavigator.new(board.copy, navigator_factory)
    board_after_move.board.move_piece(start, target)
    board_after_move.under_check?(board_after_move.king_for(target))
  end

  def enemy_moves(piece_navigator)
    piece_navigator.enemy_coordinates(board.coordinates).map { |coordinate| moves_after_collision_for(coordinate) }
  end

  def promoteable?(coordinate)
    return true if board.find_piece(coordinate).promoteable?

    false
  end

  def win?(current_players_colour)
    enemy_king = board.find_kings.find { |king| king.colour != current_players_colour }
    return true if moves_for(enemy_king.position.to_s).empty? && under_check?(enemy_king)

    false
  end

  def move_piece(start, target)
    board.move_piece(start, target)
  end

  def promote(coordinate, chosen_piece)
    piece_to_promote = piece_for(coordinate)
    promoted_piece = board.create_piece(chosen_piece, position: coordinate, colour: piece_to_promote.colour)
    board.put(promoted_piece, piece_to_promote.position)
    promoted_piece
  end

  def create_en_passant_coordinate(move)
    piece = piece_for(move.target)

    case piece.colour
    when 'white'
      @en_passant_pair = create_passant_pair(piece, move.target.down)
    when 'black'
      @en_passant_pair = create_passant_pair(piece, move.target.up)
    end
  end

  def clear_en_passant_coordinate
    @en_passant_pair = create_passant_pair(nil, nil)
  end

  def en_passant_coordinate
    @en_passant_pair&.en_passant_coordinate
  end

  def create_passant_pair(piece, coordinate)
    EnPassantPair.new(piece, coordinate)
  end
end
