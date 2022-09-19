# frozen_string_literal: true

require_relative '../piece'

# This class handles a Rook chesspiece.
class Rook < Piece
  # def legal?(space)
  #   to_coordinate = Coordinate.parse(space)
  #   return false if position == to_coordinate

  #   horizontal?(to_coordinate) || vertical?(to_coordinate)
  # end

  # def split_moves(moves)
  #   coordinates = moves.map { |move| Coordinate.parse(move) }
  #   split_moves = []
  #   split_moves << up(coordinates)
  #   split_moves << down(coordinates).reverse
  #   split_moves << left(coordinates).reverse
  #   split_moves << right(coordinates)
  #   split_moves
  # end

  # def up(moves)
  #   moves.select { |coordinate| position.to_up?(coordinate) }
  # end

  # def down(moves)
  #   moves.select { |coordinate| position.to_down?(coordinate) }
  # end

  # def left(moves)
  #   moves.select { |coordinate| position.to_left?(coordinate) }
  # end

  # def right(moves)
  #   moves.select { |coordinate| position.to_right?(coordinate) }
  # end

  # def horizontal?(space)
  #   position.same_row?(space)
  # end

  # def vertical?(space)
  #   position.same_column?(space)
  # end

  def to_fen
    case colour
    when 'white' then 'R'
    when 'black' then 'r'
    end
  end

  def can_castle?
    return true unless moved?

    false
  end
end
