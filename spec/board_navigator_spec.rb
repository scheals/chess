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

    context 'when piece is found' do
      subject(:navigator) { described_class.new(board, navigator_factory) }

      let(:bishop) { instance_double(Bishop, position: coordinate.parse('f4'), colour: 'white') }
      let(:board) { instance_double(Board) }
      let(:navigator_factory) { class_double(NavigatorFactory) }
      let(:bishop_navigator) { instance_double(BishopNavigator, board:, piece: bishop) }
      let(:pieceful_coordinate) { 'f4' }

      before do
        allow(board).to receive(:find_piece).with(pieceful_coordinate).and_return(bishop).twice
        allow(navigator_factory).to receive(:for).with(board, bishop).and_return(bishop_navigator)
        allow(bishop_navigator).to receive(:possible_moves).and_return(%w[b8 c1 c7 d2 d6 e3 e5 g3 g5 h2 h6])
      end

      it 'sends Board a find_piece message twice' do
        navigator.moves_for(pieceful_coordinate)
        expect(board).to have_received(:find_piece).with(pieceful_coordinate).twice
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
      subject(:navigator) { described_class.new(board, navigator_factory) }

      let(:navigator_factory) { class_double(NavigatorFactory) }
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

  describe '#under_check?' do
    context 'when called' do
      subject(:checking_check) { described_class.new(board, navigator_factory) }

      let(:navigator_factory) { class_double(NavigatorFactory) }
      let(:board) { instance_double(Board) }
      let(:king) { instance_double(King) }
      let(:king_navigator) { instance_double(KingNavigator) }

      before do
        allow(navigator_factory).to receive(:for).with(board, king).and_return(king_navigator)
        allow(board).to receive(:coordinates).and_return(%w[a1 a2])
        allow(king).to receive(:position).and_return('a1')
        allow(king_navigator).to receive(:enemy_coordinates).and_return([])
      end

      it 'always sends NavigatorFactory a for message with a King' do
        checking_check.under_check?(king)
        expect(navigator_factory).to have_received(:for).with(board, king)
      end
    end

    context 'when King is under check' do
      subject(:navigate_check) { described_class.new(board) }

      let(:board) { Board.new }

      before do
        board.setup('r6K/8/8/r7/8/8/8/8')
      end

      it 'returns true' do
        king = board.find_piece('h8')
        expect(navigate_check.under_check?(king)).to be true
      end
    end

    context 'when King is not under check' do
      subject(:navigate_checkless) { described_class.new(board) }

      let(:board) { Board.new }

      before do
        board.setup('k7/1R6/8/8/8/8/8/7r')
      end

      it 'returns false' do
        king = board.find_piece('a8')
        expect(navigate_checkless.under_check?(king)).to be false
      end
    end
  end
  # rubocop: enable RSpec/MultipleMemoizedHelpers
end
