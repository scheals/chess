# frozen_string_literal: true

# This class handles a square on a chessboard.
class Square
  def initialize(coordinates = nil)
    @coordinates = coordinates
    @piece = nil
  end

  def place(piece)
    return nil if @piece

    @piece = piece
  end

  def vacate
    return nil unless @piece

    @piece = nil
  end
end
