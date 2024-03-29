# frozen_string_literal: true

# This module holds the various moves.
module Moves
  # This module holds horizontal moves.
  module HorizontalMoves
    def horizontal_moves
      go_up + go_down + go_left + go_right
    end

    def go_left
      queue = [piece.position.left]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move if empty_or_enemy?(current_square)
        queue.push(move.left) if passable?(move.left, current_square)
      end
      moves
    end

    def go_right
      queue = [piece.position.right]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move if empty_or_enemy?(current_square)
        queue.push(move.right) if passable?(move.right, current_square)
      end
      moves
    end

    def go_up
      queue = [piece.position.up]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move if empty_or_enemy?(current_square)
        queue.push(move.up) if passable?(move.up, current_square)
      end
      moves
    end

    def go_down
      queue = [piece.position.down]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move if empty_or_enemy?(current_square)
        queue.push(move.down) if passable?(move.down, current_square)
      end
      moves
    end
  end

  # This module holds diagonal moves.
  module DiagonalMoves
    def diagonal_moves
      go_up_left + go_up_right + go_down_left + go_down_right
    end

    def go_up_left
      queue = [piece.position.up.left]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move if empty_or_enemy?(current_square)
        queue.push(move.up.left) if passable?(move.up.left, current_square)
      end
      moves
    end

    def go_up_right
      queue = [piece.position.up.right]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move if empty_or_enemy?(current_square)
        queue.push(move.up.right) if passable?(move.up.right, current_square)
      end
      moves
    end

    def go_down_left
      queue = [piece.position.down.left]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move if empty_or_enemy?(current_square)
        queue.push(move.down.left) if passable?(move.down.left, current_square)
      end
      moves
    end

    def go_down_right
      queue = [piece.position.down.right]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move if empty_or_enemy?(current_square)
        queue.push(move.down.right) if passable?(move.down.right, current_square)
      end
      moves
    end
  end

  # This module holds takes for Pawns.
  module PawnTakes
    def white_takes
      coordinates = [piece.position.left.up, piece.position.right.up].select { |coordinate| board.find(coordinate) }
      enemy_coordinates(coordinates)
    end

    def black_takes
      coordinates = [piece.position.left.down, piece.position.right.down].select { |coordinate| board.find(coordinate) }
      enemy_coordinates(coordinates)
    end
  end

  # This module handles forward movement for Pawns.
  module PawnForward
    def white_forward
      return white_double unless piece.moved?

      forward = piece.position.up
      move = []
      move << forward unless board.find(forward).occupied?
      move
    end

    def white_double
      queue = [piece.position.up]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move unless current_square.occupied?
        queue.push(move.up) if passable?(move.up, current_square) && moves.size < 2
      end
      moves
    end

    def black_forward
      return black_double unless piece.moved?

      forward = piece.position.down
      move = []
      move << forward unless board.find(forward).occupied?
      move
    end

    def black_double
      queue = [piece.position.down]
      moves = []
      until queue.empty?
        move = queue.shift
        current_square = board.find(move)
        break unless current_square

        moves << move unless current_square.occupied?
        queue.push(move.down) if passable?(move.down, current_square) && moves.size < 2
      end
      moves
    end
  end

  # This module holds moves that don't care for collision.
  module CollisionlessMoves
    def collisionless_moves
      moves = legal_for(piece)
      moves.reject { |move| allied_coordinates(moves).include?(move) }
    end
  end
end
