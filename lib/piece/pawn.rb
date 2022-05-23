# frozen_string_literal: true

require_relative '../piece'

# This class handles a Pawn chesspiece rules.
class Pawn < Piece
  def legal?(space)
    return false if space == position

    once_diagonal?(space) || (once_vertical?(space) && same_column?(space)) || (double_vertical?(space) && same_column?(space))
  end

  def split_moves(moves)
    split_moves = []
    split_moves << up(moves) if colour == 'white'
    split_moves << down(moves).reverse if colour == 'black'
    split_moves << left(moves).reverse
    split_moves << right(moves)
    split_moves
  end

  def up(moves)
    moves.select { |coordinate| coordinate[1].to_i > position[1].to_i && same_column?(coordinate) }
  end

  def down(moves)
    moves.select { |coordinate| coordinate[1].to_i < position[1].to_i && same_column?(coordinate) }
  end

  def left(moves)
    moves.select { |coordinate| coordinate[0].ord < position[0].ord }
  end

  def right(moves)
    moves.select { |coordinate| coordinate[0].ord > position[0].ord }
  end

  def handle_collision(moves)
    case colour
    when 'white'
      handle_white_pawn(moves)
    when 'black'
      handle_black_pawn(moves)
    end
  end

  def handle_white_pawn(moves)
    takes = (left(moves) + right(moves)).select { |coordinate| coordinate.end_with?('E') }
    forward = up(moves).reject { |coordinate| coordinate.end_with?('E') }
    [forward, takes]
  end

  def handle_black_pawn(moves)
    takes = (left(moves) + right(moves)).select { |coordinate| coordinate.end_with?('E') }
    forward = down(moves).reject { |coordinate| coordinate.end_with?('E') }
    [forward, takes]
  end

  def double_vertical?(space)
    return false if moved?

    if colour == 'black'
      black_double?(space)
    else
      white_double?(space)
    end
  end

  def black_double?(space)
    (space[1].to_i - row.to_i) == -2
  end

  def white_double?(space)
    (space[1].to_i - row.to_i) == 2
  end

  def once_diagonal?(space)
    once_vertical?(space) && once_horizontal?(space)
  end

  def once_vertical?(space)
    if colour == 'black'
      black_vertical?(space)
    else
      white_vertical?(space)
    end
  end

  def black_vertical?(space)
    (space[1].to_i - row.to_i) == -1
  end

  def white_vertical?(space)
    (space[1].to_i - row.to_i) == 1
  end

  def once_horizontal?(space)
    space[0].succ == column || column.succ == space[0]
  end

  def same_column?(space)
    space[0] == column
  end

  def same_row?(space)
    space[1] == row
  end
end
