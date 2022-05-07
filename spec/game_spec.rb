# frozen_string_literal: true

require_relative '../lib/game'

# rubocop: disable Metrics/BlockLength, Lint/AmbiguousBlockAssociation, Layout/LineLength, Style/NestedParenthesizedCalls
describe Game do
  describe '#find' do
    context 'when the square with given coordinates exists' do
      subject(:possible_square) { described_class.new }
      let(:board) { possible_square.instance_variable_get(:@board) }
      it 'returns the square' do
        a1_square = board['a1']
        expect(possible_square.find('a1')).to be(a1_square)
      end
    end
    context 'when the square with given coordinates does not exist' do
      subject(:impossible_square) { described_class.new }
      it 'returns nil' do
        expect(impossible_square.find('b20')).to be_nil
      end
    end
  end

  describe '#put' do
    context 'when square is empty' do
      subject(:empty_board) { described_class.new }
      let(:piece) { instance_double(Piece) }
      let(:empty_square) { empty_board.find('d6') }
      it 'sends that square a #place message' do
        expect(empty_square).to receive(:place)
        empty_board.put(piece, 'd6')
      end
    end
    context 'when square is occupied' do
      subject(:full_board) { described_class.new }
      let(:piece) { instance_double(Piece) }
      let(:another_piece) { instance_double(Piece) }
      let(:occupied_square) { full_board.find('a2') }
      before do
        occupied_square.place(piece)
        allow(piece).to receive(:real?).and_return(true)
      end
      it 'returns nil' do
        expect(full_board.put(piece, 'a2')).to be_nil
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength, Lint/AmbiguousBlockAssociation, Layout/LineLength, Style/NestedParenthesizedCalls
