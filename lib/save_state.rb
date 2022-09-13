# frozen_string_literal: true

# This class handles parsing the fen string to a loadable state.
class SaveState
  def initialize(fen_string)
    split_fen = fen_string.split
    @board = split_fen[0]
    @current_player = split_fen[1]
    @castling_rights = split_fen[2]
    @en_passant_coordinate = split_fen[3]
    @half_move_clock = split_fen[4].to_i
    @full_move_clock = split_fen[5].to_i
  end

  def game_state
    { current_player:, half_move_clock:, full_move_clock: }
  end

  def board_state
    { board:, castling_rights:, en_passant_coordinate: }
  end

  private

  attr_reader :board, :current_player, :castling_rights, :en_passant_coordinate,
              :half_move_clock, :full_move_clock
end
