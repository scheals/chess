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

    context 'when fifty move rule ends the game' do
      subject(:fifty_move_finish) { described_class.new }

      before do
        timman_lutz_1995_partial = %w[g7g3 h4h1 b5c6 h1e1 c5d4 e1c1 d4c3 c1d1 g3e3 e6f5 c6c5 d1d8 c3e5 d8c8 c5d5 c8a8 e3f3 f5g4 f3f7 a8a5 d5e4 a5a4 e5d4 g4g5 f7g7 g5h4 e4e5 h4h3 g7g1 a4b4 d4e3 b4g4 g1a1 h3g2 e3f4 g4g8 a1a2 g2f3 a2a3 f3e2 e5e4 g8e8 f4e5 e8e7 a3a2 e2e1 e4d4 e1f1 e5f4 e7e2 a2a8 e2e7 d4d3 f1g2 a8f8 e7e6 f8f7 e6e8 f4e3 e8a8 e3c5 a8a4 d3e3 a4g4 c5d6 g4g6 f7f2 g2h3 d6e5 h3g4 e3e4 g4h5 e5f6 h5g4 f2f4 g4g3 e4e3 g3h3 f4f5 g6g3 e3f2 g3g2 f2f1 g2c2 f5g5 c2c4 f6e5 h3h4 g5g8 c4e4 h4h5 f1f2 e4a4 f2f3 h5h6 g3e5 a4b4 e5f4 h6h7 g8g5 b4a4 f3g4 a4b4 g4f5 b4b5]

        fifty_move_finish.board_navigator.board.setup('8/6R1/4k3/1KB5/7r/6p1/8/8')
        allow(fifty_move_finish).to receive(:gets).and_return('g7g3','h4h1','b5c6','h1e1','c5d4','e1c1','d4c3','c1d1','g3e3','e6f5','c6c5','d1d8','c3e5','d8c8','c5d5','c8a8','e3f3','f5g4','f3f7','a8a5','d5e4','a5a4','e5d4','g4g5','f7g7','g5h4','e4e5','h4h3','g7g1','a4b4','d4e3','b4g4','g1a1','h3g2','e3f4','g4g8','a1a2','g2f3','a2a3','f3e2','e5e4','g8e8','f4e5','e8e7','a3a2','e2e1','e4d4','e1f1','e5f4','e7e2','a2a8','e2e7','d4d3','f1g2','a8f8','e7e6','f8f7','e6e8','f4e3','e8a8','e3c5','a8a4','d3e3','a4g4','c5d6','g4g6','f7f2','g2h3','d6e5','h3g4','e3e4','g4h5','e5f6','h5g4','f2f4','g4g3','e4e3','g3h3','f4f5','g6g3','e3f2','g3g2','f2f1','g2c2','f5g5','c2c4','f6e5','h3h4','g5g8','c4e4','h4h5','f1f2','e4a4','f2f3','h5h6','g3e5','a4b4','e5f4','h6h7','g8g5','b4a4','f3g4','a4b4','g4f5','b4b5')
        allow(fifty_move_finish).to receive(:puts)
      end

      it 'correctly reflects that by ending the loop' do
        expect { fifty_move_finish.game_loop }.not_to change(fifty_move_finish, :current_player)
      end
    end
  end
end
