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

  def up
    row_up = (row.ord + 1).chr
    Coordinate.parse([column, row_up].join)
  end

  def down
    row_down = (row.ord - 1).chr
    Coordinate.parse([column, row_down].join)
  end

  def left
    column_right = (column.ord - 1).chr
    Coordinate.parse([column_right, row].join)
  end

  def right
    column_left = (column.ord + 1).chr
    Coordinate.parse([column_left, row].join)
  end

  def to_left?(coordinate)
    Coordinate.parse(coordinate).column.ord < column.ord
  end

  def to_right?(coordinate)
    Coordinate.parse(coordinate).column.ord > column.ord
  end

  def to_s
    [column, row].join
  end
end
