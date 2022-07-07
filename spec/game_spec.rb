# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board_navigator'
require_relative '../lib/board'

describe Game do
  describe '#pick_piece' do
    context 'when piece belongs to current player' do
      subject(:valid_piece_picking) { described_class.new(player_white, player_black, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:board) { instance_double(Board) }
      let(:white_piece) { instance_double(Piece, colour: :white) }
      let(:player_white) { instance_double(Player, colour: :white) }
      let(:player_black) { instance_double(Player, colour: :black) }

      before do
        valid_piece_picking.current_player = player_white
        allow(board_navigator).to receive(:piece_for).with('a1').and_return(white_piece)
      end

      it 'returns the picked piece' do
        expect(valid_piece_picking.pick_piece('a1')).to be(white_piece)
      end
    end

    context 'when piece does not belong to current player' do
      subject(:invalid_piece_picking) { described_class.new(player_black, player_white, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:board) { instance_double(Board) }
      let(:white_piece) { instance_double(Piece, colour: :white) }
      let(:player_black) { instance_double(Player, colour: :black) }
      let(:player_white) { instance_double(Player, colour: :white) }

      before do
        invalid_piece_picking.current_player = player_black
        allow(board_navigator).to receive(:piece_for).with('a2').and_return(white_piece)
      end

      it 'returns nil' do
        expect(invalid_piece_picking.pick_piece('a2')).to be_nil
      end
    end
  end

  describe '#create_move' do
    subject(:game_move) { described_class.new }

    let(:move_system) { class_double(Move) }
    let(:coordinate) { 'a4b6' }

    before do
      allow(move_system).to receive(:parse).with(coordinate)
    end

    it 'sends Move a parse message' do
      game_move.create_move(coordinate, move_system)
      expect(move_system).to have_received(:parse).with(coordinate)
    end
  end
end
