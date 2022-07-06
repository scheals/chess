# frozen_string_literal: true

# This class handles players.
class Player
  attr_accessor :name, :colour

  def initialize(name = nil, colour = nil)
    @name = name
    @colour = colour
  end
end
