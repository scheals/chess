# frozen_string_literal: true

require_relative './lib/board_navigator'
require_relative './lib/board'
require_relative './lib/coordinate'
require_relative './lib/display'
require_relative './lib/game'
require_relative './lib/move'
require_relative './lib/moves'
require_relative './lib/navigator_factory'
require_relative './lib/piece_factory'
require_relative './lib/piece_navigator'
require_relative './lib/piece'
require_relative './lib/player'
require_relative './lib/square'
require_relative './lib/piece/bishop'
require_relative './lib/piece/king'
require_relative './lib/piece/knight'
require_relative './lib/piece/nil_piece'
require_relative './lib/piece/pawn'
require_relative './lib/piece/queen'
require_relative './lib/piece/rook'
require_relative './lib/navigator/bishop_navigator'
require_relative './lib/navigator/king_navigator'
require_relative './lib/navigator/knight_navigator'
require_relative './lib/navigator/pawn_navigator'
require_relative './lib/navigator/queen_navigator'
require_relative './lib/navigator/rook_navigator'

test_game = Game.new
test_game.board_navigator.board.setup
test_game.game_loop
