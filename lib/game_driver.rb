# frozen_string_literal: true

# This module handles creating a game session.
module GameDriver
  def self.setup
    puts 'Who is playing as white?'
    player1 = Player.new(gets.chomp, 'white')
    puts 'Who is playing as black?'
    player2 = Player.new(gets.chomp, 'black')
    game = Game.new(player1, player2)
    puts 'Are you loading a game? Y/n'
    loading_choice = gets.chomp
    return attempt_to_load(game) if loading_choice.downcase == 'y'

    setup_fresh(game)
  end

  def self.attempt_to_load(game)
    return no_save_directory(game) unless Dir.exist?('savegames')

    savegames = get_savegame_names
    return empty_save_directory(game) if savegames.empty?

    load(game, choose_save(savegames))
    game
  end

  def self.load(game, save)
    fen_string = nil
    File.open("savegames/#{save}", 'r') do |file|
      fen_string = file.gets.chomp
    end
    game.load(fen_string)
  end

  def self.choose_save(savegames)
    puts 'Which game would you like to load? Type in its number.'
    savegames.each_with_index { |save, index| puts "#{index + 1}.\s #{save}" }
    loop do
      choice = gets.chomp.to_i
      break savegames[choice - 1] if valid_save?(savegames, choice)
    end
  end

  def self.valid_save?(savegames, choice)
    return true if (1..(savegames.size)).include?(choice)

    puts 'Incorrect input!'
    false
  end

  def self.get_savegame_names
    Dir.entries('savegames').reject { |entry| entry.include?('.') }
  end

  def self.no_save_directory(game)
    puts 'Directory savegames not found! Starting a new game.'
    setup_fresh(game)
  end

  def self.empty_save_directory(game)
    puts 'No save games found! Starting a new game.'
    setup_fresh(game)
  end

  def self.setup_fresh(game)
    starting_board = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR'
    game.setup_board(starting_board)
    game
  end

  def self.start(game)
    puts game.display.greeting
    loop do
      puts game.display.turn_beginning(game.current_player, game.board)
      move = game.ask_for_move until move
      return game.save_game if move.to_s == 'save'

      game.calculate_halfmove_clock(move)
      game.move_piece(move)
      game.promote(move.target) if game.promoteable?(move.target)
      game.castle(move) if game.castling?(move)
      game.handle_en_passant(move)
      game.increment_fullmove_clock if game.black_finished_move?
      game.store_history
      break if game.game_over?

      game.switch_players
    end
    puts game.display.show(game.board)
    puts game.display.thanks(game.player1, game.player2)
  end
end
