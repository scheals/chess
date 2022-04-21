# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/square'

# rubocop: disable Metrics/BlockLength, Lint/AmbiguousBlockAssociation, Layout/LineLength
describe Board do
  describe '#initialize' do
    subject(:new_board) { described_class.new(square) }
    let(:square) { instance_double(Square) }
    it 'stores an array of length 8 in board instance variable' do
      expect(new_board.instance_variable_get(:@board).length).to be(8)
    end
    it 'board array is made of arrays of length 8' do
      expect(new_board.instance_variable_get(:@board)).to all(satisfy { |row| row.length == 8 })
    end
    it 'board is composed of objects resembling squares' do
      expect(new_board.instance_variable_get(:@square)).to be(square)
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
end
# rubocop: enable Metrics/BlockLength, Lint/AmbiguousBlockAssociation, Layout/LineLength
