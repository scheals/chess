# frozen_string_literal: true

require_relative '../chess'

# This class takes care of saving games into FEN strings.
class FENSerializer
  attr_reader :game, :board

  def initialize(game)
    @game = game
    @board = game.board
  end

  def self.from_game(game, full: true)
    new(game).game_to_fen(full:)
  end

  def game_to_fen(full: true)
    result = []
    result << pieces_to_fen
    result << game.current_player.colour[0]
    result << record_castling_rights
    result << record_en_passant_coordinate
    result << game.half_move_clock if full
    result << game.full_move_clock if full
    result.join(' ')
  end

  def pieces_to_fen
    fen = ''
    8.downto(1) do |row_number|
      fen += board.row(row_number).values.map { |square| square.piece.to_fen }.join
      fen += '/' unless row_number == 1
    end
    fen.gsub(/(\d)+/) { |match| match.count('1') }
  end

  def record_en_passant_coordinate
    return board.en_passant_coordinate.to_s if board.en_passant_coordinate

    '-'
  end

  def record_castling_rights
    castling_rights = []
    colours = %w[white black]

    colours.each do |colour|
      letters = %w[K Q]
      letters.map!(&:downcase) if colour == 'black'
      castling_rights << letters.first if kingside_castling_rights?(colour)
      castling_rights << letters.last if queenside_castling_rights?(colour)
    end

    return '-' if castling_rights.empty?

    castling_rights.join
  end

  def queenside_castling_rights?(colour)
    return false unless board.castling_rights["#{colour}_queenside".to_sym]

    case colour
    when 'white'
      king = board.piece_for('e1')
      queenside_rook = board.piece_for('a1')
    when 'black'
      king = board.piece_for('e8')
      queenside_rook = board.piece_for('a8')
    end
    return true if king.can_castle? &&
                   queenside_rook.can_castle?

    false
  end

  def kingside_castling_rights?(colour)
    return false unless board.castling_rights["#{colour}_kingside".to_sym]

    case colour
    when 'white'
      king = board.piece_for('e1')
      kingside_rook = board.piece_for('h1')
    when 'black'
      king = board.piece_for('e8')
      kingside_rook = board.piece_for('h8')
    end

    return true if king.can_castle? &&
                   kingside_rook.can_castle?

    false
  end
end
