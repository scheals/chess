# frozen_string_literal: true

# rubocop: disable Metrics/ModuleLength
# This module handles a console display.
module Display
  WHITE_TILES = %w[a2 a4 a6 a8 b1 b3 b5 b7 c2 c4 c6 c8 d1 d3 d5 d7 e2 e4 e6 e8 f1 f3 f5 f7 g2 g4 g6 g8 h1 h3 h5 h7].freeze
  BLACK_TILES = %w[a1 a3 a5 a7 b2 b4 b6 b8 c1 c3 c5 c7 d2 d4 d6 d8 e1 e3 e5 e7 f2 f4 f6 f8 g1 g3 g5 g7 h2 h4 h6 h8].freeze

  def self.greeting
    <<~HEREDOC
      Welcome to Chess by Scheals!

      Currently, there are no voluntary draws - threefold repetition and fifty move rule
      force a tie the moment they happen. You can't offer draw either.

      Hope you'll have fun playing! <3

    HEREDOC
  end

  def self.turn_beginning(player, board)
    <<~HEREDOC
      This is how the board looks like:
      #{show(board)}
      #{player.name} as #{player.colour} it is your turn!
      Enter a full move like \'a8c8\' or a partial move like \'a8\' to see possible moves of that piece.

    HEREDOC
  end

  def self.possible_moves(moves, board)
    <<~HEREDOC
      #{highlight_moves(moves, board)}
      Those are your possible moves:
      #{moves.each { |move| print "#{move} \t" }}
      Which one do you want to make? Type 'q' if you want to restart making your move.

    HEREDOC
  end

  def self.promotion(player)
    <<~HEREDOC
      #{player.name} promote your Pawn! FEN and full names accepted.
    HEREDOC
  end

  def self.piece_not_owned(coordinate)
    puts "You do not own piece at #{coordinate}."
  end

  def self.move_impossible_for_piece
    puts 'This move can not be made by this piece.'
  end

  def self.move_no_target
    puts 'Your move lacks a target.'
  end

  def self.move_wrong_length
    puts 'Your move is either too long or too short in length.'
  end

  def self.move_out_of_bounds
    puts 'Your move is out of bounds.'
  end

  def self.incorrect_input
    puts 'Incorrect input!'
  end

  def self.thanks(player1, player2)
    <<~HEREDOC
      Thanks for playing, #{player1.name} and #{player2.name}!
    HEREDOC
  end

  def self.congratulate(winner)
    <<~HEREDOC
      Checkmate! Congratulations, #{winner.name}!
    HEREDOC
  end

  def self.stalemate(player1, player2)
    <<~HEREDOC
      It's a tie between #{player1.name} and #{player2.name} due to stalemate!
    HEREDOC
  end

  def self.threefold_tie(player1, player2)
    <<~HEREDOC
      It's a tie between #{player1.name} and #{player2.name} due to threefold repetition!
    HEREDOC
  end

  def self.fifty_moves_tie(player1, player2)
    <<~HEREDOC
      It's a tie between #{player1.name} and #{player2.name} due to fifty move rule!
    HEREDOC
  end

  def self.show(board, moves = [])
    stringified_moves = moves.map(&:to_s)
    8.times do |i|
      print_row(board, stringified_moves, 8 - i)
      puts "\n"
    end
    print_column_letters
  end

  def self.print_row(board, moves, row_number)
    print row_number
    board.row(row_number).each_value do |tile|
      next print_highlight(tile) if moves.include?(tile.position.to_s)
      next print_white(tile) if WHITE_TILES.include?(tile.position.to_s)
      next print_black(tile) if BLACK_TILES.include?(tile.position.to_s)
    end
  end

  def self.print_column_letters
    puts "\sa\sb\sc\sd\se\sf\sg\sh"
  end

  def self.highlight_moves(board, moves)
    show(board, moves)
  end

  def self.print_highlight(tile)
    print "\e[102m#{tile}\e[0m"
  end

  def self.print_white(tile)
    print "\e[0;100m#{tile}\e[0m"
  end

  def self.print_black(tile)
    print "\e[44;2m#{tile}\e[0m"
  end
end
# rubocop: enable Metrics/ModuleLength
