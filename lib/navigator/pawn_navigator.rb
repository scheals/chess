# frozen_string_literal: true

require_relative '../piece_navigator'
require_relative '../moves'

# This class handles collision for Pawn pieces.
class PawnNavigator < PieceNavigator
  attr_reader :piece

  include Moves::PawnForward
  include Moves::PawnTakes

  def initialize(board_navigator, piece)
    super
    @board_navigator = board_navigator
  end

  def possible_moves
    handle_pawn + en_passant
  end

  def handle_pawn
    if piece.colour == 'white'
      white_forward + white_takes
    else
      black_forward + black_takes
    end
  end

  def en_passant
    if piece.colour == 'white'
      white_en_passant
    else
      black_en_passant
    end
  end

  def en_passant_checks_king?(start, target)
    board_after_move = BoardNavigator.new(board.copy, @board_navigator.navigator_factory)
    board_after_move.board.move_piece(start, target)
    if piece.colour == 'white'
      white_passant_capture(board_after_move)
    else
      black_passant_capture(board_after_move)
    end
    board_after_move.under_check?(board_after_move.board.king_for(target))
  end

  def white_en_passant
    en_passant_coordinate = board.en_passant_coordinate
    move = []
    return move << en_passant_coordinate if (en_passant_coordinate == piece.position.up.left || en_passant_coordinate == piece.position.up.right) &&
                                            !en_passant_checks_king?(piece.position, en_passant_coordinate)

    move
  end

  def black_en_passant
    en_passant_coordinate = board.en_passant_coordinate
    move = []
    return move << en_passant_coordinate if (en_passant_coordinate == piece.position.down.left || en_passant_coordinate == piece.position.down.right) &&
                                            !en_passant_checks_king?(piece.position, en_passant_coordinate)

    move
  end

  def white_passant_capture(board_after_move)
    board_after_move.board.find(board.en_passant_coordinate.down).vacate
  end

  def black_passant_capture(board_after_move)
    board_after_move.board.find(board.en_passant_coordinate.up).vacate
  end
end
