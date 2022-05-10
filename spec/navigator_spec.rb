# frozen_string_literal: true

require_relative '../lib/boardnavigator'
require_relative '../lib/knight'
require_relative '../lib/board'

# rubocop: disable Metrics/BlockLength,Layout/LineLength,
describe BoardNavigator do
  describe '#in_bounds_moves' do
    context "when checking Kings's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:king) { King.new('d4') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(king)).to contain_exactly('d3', 'd5', 'c3', 'c4', 'c5', 'e3', 'e4', 'e5')
      end
    end

    context "when checking Knight's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:knight) { Knight.new('b8') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(knight)).to contain_exactly('a6', 'c6', 'd7')
      end
    end

    xcontext "when checking Pawns's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:pawn) { Pawn.new('a4') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(pawn)).to contain_exactly('a6', 'c6', 'd7')
      end
    end

    xcontext "when checking Queens's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:queen) { Queen.new('c3') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(queen)).to contain_exactly('a6', 'c6', 'd7')
      end
    end

    xcontext "when checking Rook's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:rook) { Rook.new('b3') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(rook)).to contain_exactly('a6', 'c6', 'd7')
      end
    end

    xcontext "when checking Bishop's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:Bishop) { Bishop.new('e4') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(bishop)).to contain_exactly('a6', 'c6', 'd7')
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength,Layout/LineLength,
