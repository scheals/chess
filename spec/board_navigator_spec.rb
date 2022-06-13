# frozen_string_literal: true

require_relative '../lib/board_navigator'
require_relative '../lib/board'
require_relative '../lib/navigator_factory'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

describe BoardNavigator do
  describe '#moves_for' do
    subject(:navigator) { described_class.new(board) }

    let(:coordinate) { Coordinate }
    let(:board) { instance_double(Board) }
    let(:bishop) { instance_double(Bishop, position: coordinate.parse('f4'), colour: 'white') }
    let(:navigator_factory) { class_double(NavigatorFactory) }
    let(:bishop_navigator) { instance_double(BishopNavigator) }

    before do
      pieceful_coordinate = 'f4'
      empty_coordinate = 'a1'
      allow(board).to receive(:find_piece).with(pieceful_coordinate).and_return(bishop)
      allow(board).to receive(:find_piece).with(empty_coordinate).and_return(nil)
      allow(navigator_factory).to receive(:for).with(board, bishop).and_return(bishop_navigator)
      allow(bishop_navigator).to receive(:possible_moves)
    end

    it 'sends Board a find_piece message' do
      pieceful_coordinate = 'f4'
      navigator.moves_for(pieceful_coordinate)
      expect(board).to have_received(:find_piece).with(bishop)
    end

    context 'when piece is found' do
      it 'sends NavigatorFactory a for message' do
        pieceful_coordinate = 'f4'
        navigator.moves_for(pieceful_coordinate)
        expect(NavigatorFactory).to have_received(:for).with(board, bishop)
      end

      it 'sends NavigatorPiece a possible_moves message' do
        pieceful_coordinate = 'f4'
        navigator.moves_for(pieceful_coordinate)
        expect(BishopNavigator).to have_received(:possible_moves)
      end

      it 'returns correct moves' do
        pieceful_coordinate = 'f4'
        correct_moves = %w[b8 c1 c7 d2 d6 e3 e5 g3 g5 h2 h6]
        expect(navigator_moves_for(pieceful_coordinate)).to eq(correct_moves)
      end
    end

    context 'when piece is not found' do
      it "doesn't send NavigatorFactory a message" do
        empty_coordinate = 'a1'
        navigator.moves_for(empty_coordinate)
        expect(NavigatorFactory).not_to have_received(:for)
      end

      it 'returns nil' do
        empty_coordinate = 'a1'
        expect(navigator.moves_for(empty_coordinate)).to be_nil
      end
    end
  end
end
