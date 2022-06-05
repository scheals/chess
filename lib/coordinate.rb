# frozen_string_literal: true

# This class handles coordinates on a two-dimensional board.
class Coordinate
  attr_reader :column, :row

  def initialize(string)
    @column = string[0]
    @row = string[1]
  end

  def self.parse(coordinate)
    return coordinate if coordinate.is_a?(Coordinate)

    new(coordinate)
  end

  def ==(other)
    column == other.column && row == other.row
  end

  def same_column?(coordinate)
    column == coordinate.column
  end

  def same_row?(coordinate)
    row == coordinate.row
  end
end
