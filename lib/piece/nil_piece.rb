# frozen_string_literal: true

require_relative '../piece'

# This class handles abstract chess empty pieces.
class NilPiece < Piece
  def to_s
    ' '
  end

  def real?
    false
  end

  def to_fen
    '1'
  end
end
