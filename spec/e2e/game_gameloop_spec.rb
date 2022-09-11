# frozen_string_literal: true

require_relative '../../lib/game'
require_relative '../../lib/board_navigator'
require_relative '../../lib/board'

describe Game do
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

    context 'when threefold repetition ends the game' do
      subject(:threefold_finish) { described_class.new }

      before do
        portisch_korchnoi_1970 = ['g1f3', 'c7c5', 'c2c4', 'g8f6', 'b1c3', 'b8c6', 'd2d4', 'c5d4', 'f3d4', 'e7e6', 'g2g3', 'd8b6',
                                  'd4b3', 'c6e5', 'e2e4', 'f8b4', 'd1e2', 'e8g8',  'f2f4', 'e5c6', 'e4e5', 'f6e8', 'c1d2',
                                  'f7f6', 'c4c5', 'b6d8', 'a2a3', 'b4c3', 'd2c3', 'f6e5', 'c3e5', 'b7b6', 'f1g2',
                                  'c6e5', 'g2a8', 'e5f7', 'a8g2', 'b6c5', 'b3c5', 'd8b6',  'e2f2', 'b6b5',
                                  'g2f1', 'b5c6', 'f1g2', 'c6b5', 'g2f1', 'b5c6', 'f1g2', 'c6b5']
        threefold_finish.board_navigator.board.setup
        allow(threefold_finish).to receive(:gets).and_return('g1f3', 'c7c5', 'c2c4', 'g8f6', 'b1c3', 'b8c6', 'd2d4', 'c5d4', 'f3d4', 'e7e6', 'g2g3', 'd8b6',
                                                             'd4b3', 'c6e5', 'e2e4', 'f8b4', 'd1e2', 'e8g8', 'f2f4', 'e5c6', 'e4e5', 'f6e8', 'c1d2',
                                                             'f7f6', 'c4c5', 'b6d8', 'a2a3', 'b4c3', 'd2c3', 'f6e5', 'c3e5', 'b7b6', 'f1g2',
                                                             'c6e5', 'g2a8', 'e5f7', 'a8g2', 'b6c5', 'b3c5', 'd8b6', 'e2f2', 'b6b5',
                                                             'g2f1', 'b5c6', 'f1g2', 'c6b5', 'g2f1', 'b5c6', 'f1g2', 'c6b5')
        allow(threefold_finish).to receive(:puts)
      end

      it 'correctly reflects that by ending the loop' do
        expect { threefold_finish.game_loop }.to change(threefold_finish, :current_player)
      end
    end
  end
end
