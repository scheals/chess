# frozen_string_literal: true

require_relative '../../lib/game'
require_relative '../../lib/board_navigator'
require_relative '../../lib/board'

xdescribe Game do
  describe '#game_loop' do
    context 'when promotion ends the game' do
      subject(:promoted_to_win) { described_class.new }

      before do
        promoted_to_win.board_navigator.board.setup('4kbnr/P3pppp/8/8/8/8/1PP1PPPP/RNBQKBNR')
        allow(promoted_to_win).to receive(:gets).and_return('a7a8', 'queen')
        allow(promoted_to_win).to receive(:puts)
      end

      it 'correctly reflects that by ending the loop' do
        expect { promoted_to_win.game_loop }.not_to change(promoted_to_win, :current_player)
      end
    end

    context 'when castling ends the game' do
      subject(:castled_to_win) { described_class.new }

      before do
        castled_to_win.board_navigator.board.setup('rnb2kr1/pppp2pp/8/8/8/8/PPPPQ1PP/RNB1K2R')
        allow(castled_to_win).to receive(:gets).and_return('e1g1').once
        allow(castled_to_win).to receive(:puts)
      end

      it 'correctly reflects that by ending the loop' do
        expect { castled_to_win.game_loop }.not_to change(castled_to_win, :current_player)
      end
    end

    context "when Fool's mate occurs" do
      subject(:fools_game) { described_class.new }

      before do
        fools_game.board_navigator.board.setup
        allow(fools_game).to receive(:gets).and_return('f2f3', 'e7e6', 'g2g4', 'd8h4')
        allow(fools_game).to receive(:puts)
      end

      it 'correctly reflects that by ending the loop' do
        expect { fools_game.game_loop }.to change(fools_game, :current_player).to be(fools_game.player2)
      end
    end

    context 'when en passant ends the game' do
      subject(:en_passant_finish) { described_class.new }

      before do
        en_passant_finish.board_navigator.board.setup
        allow(en_passant_finish).to receive(:gets).and_return('e2e4', 'e7e6', 'e4e5', 'g7g5', 'b1c3', 'g8h6', 'd1h5', 'e8e7', 'c3e4', 'f7f5', 'e5f6')
        allow(en_passant_finish).to receive(:puts)
      end

      it 'correctly reflects that by ending the loop' do
        expect { en_passant_finish.game_loop }.not_to change(en_passant_finish, :current_player)
      end
    end
  end
end
