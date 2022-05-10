# frozen_string_literal: true

require_relative '../lib/boardnavigator'
require_relative '../lib/knight'
require_relative '../lib/board'

# rubocop: disable Metrics/BlockLength, Layout/LineLength,
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

    context "when checking Pawns's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:pawn) { Pawn.new('a4') }
      xit 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(pawn)).to contain_exactly('a6', 'c6', 'd7')
      end
    end

    context "when checking Queens's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:queen) { Queen.new('c3') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(queen)).to contain_exactly('c1', 'c2', 'c4', 'c5', 'c6', 'c7', 'c8',
                                                                          'a3', 'b3', 'd3', 'e3', 'f3', 'g3', 'h3',
                                                                          'a1', 'b2', 'd4', 'e5', 'f6', 'g7', 'h8',
                                                                          'b4', 'a5', 'd2', 'e1')
      end
    end

    context "when checking Rook's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:rook) { Rook.new('b3') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(rook)).to contain_exactly('b1', 'b2', 'b4', 'b5', 'b6', 'b7', 'b8',
                                                                         'a3', 'c3', 'd3', 'e3', 'f3', 'g3', 'h3')
      end
    end

    context "when checking Bishop's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:bishop) { Bishop.new('e4') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_moves(bishop)).to contain_exactly('d3', 'c2', 'b1',
                                                                           'd5', 'c6', 'b7', 'a8',
                                                                           'f3', 'g2', 'h1',
                                                                           'f5', 'g6', 'h7')
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength, Layout/LineLength,
