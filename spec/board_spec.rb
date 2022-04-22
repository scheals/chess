# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/square'

# rubocop: disable Metrics/BlockLength, Lint/AmbiguousBlockAssociation, Layout/LineLength
describe Board do
  describe '#initialize' do
    subject(:new_board) { described_class.new(square) }
    let(:square) { class_double(Square) }
    before do
      allow(square).to receive(:new).and_return(square)
    end
    it 'board is composed of objects resembling squares' do
      expect(new_board.instance_variable_get(:@board).values).to all(be(square))
    end
  end

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
      end
      it 'returns nil' do
        expect(full_board.put(piece, 'a2')).to be_nil
      end
    end
  end
end

describe Square do
  describe '#place' do
    context 'when square is not occupied by a piece' do
      subject(:empty_square) { described_class.new('c4') }
      let(:piece) { instance_double(Piece) }
      it 'stores the piece in @piece' do
        expect { empty_square.place(piece) }.to change { empty_square.instance_variable_get(:@piece) }
      end
    end
    context 'when square is occupied by a piece' do
      subject(:full_square) { described_class.new('d8') }
      let(:piece) { instance_double(Piece) }
      let(:another_piece) { instance_double(Piece) }
      before do
        full_square.place(piece)
      end
      it 'does not change @piece' do
        expect { full_square.place(another_piece) }.to_not change { full_square.instance_variable_get(:@piece) }
      end
      it 'returns nil' do
        expect(full_square.place(another_piece)).to be_nil
      end
    end
  end

  describe '#vacate' do
    context 'when square is occupied by a piece' do
      subject(:occupied_square) { described_class.new('a1') }
      let(:piece) { instance_double(Piece) }
      before do
        occupied_square.place(piece)
      end
      it 'changes @piece into nil' do
        expect { occupied_square.vacate }.to change { occupied_square.instance_variable_get(:@piece) }.from(piece).to(nil)
      end
    end
    context 'when square is empty' do
      subject(:empty_square) { described_class.new('h4') }
      it 'returns nil' do
        expect(empty_square.vacate).to be_nil
      end
    end
  end

  describe '#occupied?' do
    context 'when square is occupied by a piece' do
      subject(:pieceful_square) { described_class.new('a6') }
      let(:piece) { instance_double(Piece) }
      before do
        pieceful_square.place(piece)
      end
      it 'returns true' do
        expect(pieceful_square.occupied?).to be(true)
      end
    end
    context 'when square is empty' do
      subject(:pieceless_square) { described_class.new('g6') }
      it 'returns false' do
        expect(pieceless_square.occupied?).to be(false)
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength, Lint/AmbiguousBlockAssociation, Layout/LineLength
