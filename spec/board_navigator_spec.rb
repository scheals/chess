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
  # rubocop: disable RSpec/MultipleMemoizedHelpers
  describe '#moves_for' do
    let(:coordinate) { Coordinate }
    let(:bishop) { instance_double(Bishop, position: coordinate.parse('f4'), colour: 'white') }
    let(:navigator_factory) { class_double(NavigatorFactory) }

    context 'when piece is found' do
      subject(:navigator) { described_class.new(board) }

      let(:board) { instance_double(Board.new(square_class)) }
      let(:square_class) { class_double(Square) }
      let(:square_instance) { instance_double(Square) }
      let(:bishop_navigator) { instance_double(BishopNavigator, board:, bishop:) }
      let(:pieceful_coordinate) { 'f4' }

      before do
        coordinates = %w[a1 a2 a3 a4 a5 a6 a7 a8
                         b1 b2 b3 b4 b5 b6 b7 b8
                         c1 c2 c3 c4 c5 c6 c7 c8
                         d1 d2 d3 d4 d5 d6 d7 d8
                         e1 e2 e3 e4 e5 e6 e7 e8
                         f1 f2 f3 f4 f5 f6 f7 f8
                         g1 g2 g3 g4 g5 g6 g7 g8
                         h1 h2 h3 h4 h5 h6 h7 h8]
        allow(board).to receive(:find_piece).with(pieceful_coordinate).and_return(bishop).twice
        allow(board).to receive(:find).with(pieceful_coordinate).and_return(square_instance)
        allow(square_class).to receive(:new).and_return(square_instance)
        allow(square_instance).to receive(:piece).and_return(bishop)
        allow(board).to receive(:find_piece).and_return(nil)
        allow(board).to receive(:coordinates).and_return(coordinates)
        allow(bishop).to receive(:class).and_return(Bishop)
        allow(bishop).to receive(:legal).with(coordinates).and_return(%w[a1 a2])
        allow(bishop).to receive(:split_moves)
        allow(navigator_factory).to receive(:for).with(board, bishop).and_return(bishop_navigator)
        allow(bishop_navigator).to receive(:possible_moves)
      end

      it 'sends Board a find_piece message' do
        navigator.moves_for(pieceful_coordinate)
        expect(board).to have_received(:find_piece).with(pieceful_coordinate)
      end

      it 'sends NavigatorFactory a for message' do
        navigator.moves_for(pieceful_coordinate)
        expect(navigator_factory).to have_received(:for).with(board, bishop)
      end

      it 'sends NavigatorPiece a possible_moves message' do
        navigator.moves_for(pieceful_coordinate)
        expect(bishop_navigator).to have_received(:possible_moves)
      end

      it 'returns correct moves' do
        correct_moves = %w[b8 c1 c7 d2 d6 e3 e5 g3 g5 h2 h6]
        expect(navigator.moves_for(pieceful_coordinate)).to eq(correct_moves)
      end
    end

    context 'when piece is not found' do
      subject(:navigator) { described_class.new(board) }

      let(:empty_coordinate) { 'a1' }
      let(:board) { instance_double(Board) }

      before do
        allow(board).to receive(:find_piece).with(empty_coordinate).and_return(nil)
        allow(navigator_factory).to receive(:for)
      end

      it 'sends Board a find_piece message' do
        navigator.moves_for(empty_coordinate)
        expect(board).to have_received(:find_piece).with(empty_coordinate)
      end

      it "doesn't send NavigatorFactory a message" do
        navigator.moves_for(empty_coordinate)
        expect(navigator_factory).not_to have_received(:for)
      end

      it 'returns nil' do
        expect(navigator.moves_for(empty_coordinate)).to be_nil
      end
    end
  end
  # rubocop: enable RSpec/MultipleMemoizedHelpers
end
