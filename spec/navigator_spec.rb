# frozen_string_literal: true

require_relative '../lib/boardnavigator'
require_relative '../lib/knight'
require_relative '../lib/board'

# rubocop: disable Metrics/BlockLength, Layout/LineLength,
describe BoardNavigator do
  describe '#in_bounds_coordinates' do
    context "when checking Kings's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:king) { King.new('d4') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_coordinates(king)).to contain_exactly('d3', 'd5', 'c3', 'c4', 'c5', 'e3', 'e4', 'e5')
      end
    end

    context "when checking Knight's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:knight) { Knight.new('b8') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_coordinates(knight)).to contain_exactly('a6', 'c6', 'd7')
      end
    end

    context "when checking Pawns's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      context 'when Pawn is white' do
        let(:white_pawn) { Pawn.new('b4', colour: 'white') }
        it 'provides an array of possible moves' do
          expect(navigate_bounds.in_bounds_coordinates(white_pawn)).to contain_exactly('a5', 'b5', 'c5')
        end
      end
      context 'when Pawn is black' do
        let(:black_pawn) { Pawn.new('b4', colour: 'black') }
        it 'provides an array of possible moves' do
          expect(navigate_bounds.in_bounds_coordinates(black_pawn)).to contain_exactly('a3', 'b3', 'c3')
        end
      end
    end

    context "when checking Queens's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:queen) { Queen.new('c3') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_coordinates(queen)).to contain_exactly('c1', 'c2', 'c4', 'c5', 'c6', 'c7', 'c8',
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
        expect(navigate_bounds.in_bounds_coordinates(rook)).to contain_exactly('b1', 'b2', 'b4', 'b5', 'b6', 'b7', 'b8',
                                                                               'a3', 'c3', 'd3', 'e3', 'f3', 'g3', 'h3')
      end
    end

    context "when checking Bishop's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:bishop) { Bishop.new('e4') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_coordinates(bishop)).to contain_exactly('d3', 'c2', 'b1',
                                                                                 'd5', 'c6', 'b7', 'a8',
                                                                                 'f3', 'g2', 'h1',
                                                                                 'f5', 'g6', 'h7')
      end
    end
  end

  describe '#occupied_coordinates' do
    subject(:navigate_collison) { described_class.new(board) }
    let(:board) { Board.new }
    let(:queen) { Queen.new('d4') }
    before do
      board.setup
      board.put(queen, 'd4')
    end
    it 'returns an array of occupied squares' do
      expect(navigate_collison.occupied_coordinates(queen)).to contain_exactly('d1', 'd2', 'd7', 'd8',
                                                                               'a1', 'b2', 'g7', 'h8',
                                                                               'g1', 'f2', 'a7')
    end
  end

  describe '#allied_coordinates' do
    subject(:navigate_allies) { described_class.new(board) }
    let(:board) { Board.new }
    before do
      board.setup
    end
    it 'returns an array of squares that allied pieces are on in range of the piece' do
      white_rook = board.find_piece('a1')
      expect(navigate_allies.allied_coordinates(white_rook)).to contain_exactly('a2',
                                                                                'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1')
    end
  end

  describe '#enemy_coordinates' do
    subject(:navigate_enemies) { described_class.new(board) }
    let(:board) { Board.new }
    let(:black_rook) { Rook.new('f4', colour: 'black') }
    before do
      board.setup
      board.put(black_rook, 'f4')
    end
    it 'returns an array of squares that enemy pieces are on in range of the piece' do
      expect(navigate_enemies.enemy_coordinates(black_rook)).to contain_exactly('f1', 'f2')
    end
  end

  describe '#possible_moves' do
    subject(:navigate_possibilities) { described_class.new(board) }
    let(:board) { Board.new }
    before do
      board.setup
    end
    xit 'returns a collection of possible coordinates' do
      white_rook = board.find_piece('h1')
      expect(navigate_possibilities.possible_moves(white_rook)).to contain_exactly('g1', 'h2')
    end
  end
end
# rubocop: enable Metrics/BlockLength, Layout/LineLength,
