# frozen_string_literal: true

require_relative '../lib/rook'
require_relative '../lib/bishop'

# rubocop: disable Layout/LineLength, Metrics/BlockLength
describe Rook do
  describe '#move' do
    context 'when moved vertically' do
      subject(:vertical_move) { described_class.new('a1') }
      it 'changes its position' do
        vertical_move.move('a4')
        expect(vertical_move.position).to be('a4')
      end
    end
    context 'when moved horizontally' do
      subject(:horizontal_move) { described_class.new('b1') }
      it 'changes its position' do
        horizontal_move.move('h1')
        expect(horizontal_move.position).to be('h1')
      end
    end
    context 'when moved diagonally' do
      subject(:diagonal_move) { described_class.new('c4') }
      it "doesn't change its position" do
        diagonal_move.move('d5')
        expect(diagonal_move.position).to be('c4')
      end
      it 'returns nil' do
        expect(diagonal_move.move('b3')).to be(nil)
      end
    end
    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }
      it "doesn't change its position" do
        immovable_move.move('K0')
        expect(immovable_move.position).to be('K0')
      end
      it 'returns nil' do
        expect(immovable_move.move('K0')).to be(nil)
      end
    end
  end
end

describe Bishop do
  describe '#move' do
    context 'when moved diagonally' do
      subject(:diagonal_move) { described_class.new('c4') }
      it 'changes its position' do
        diagonal_move.move('d5')
        expect(diagonal_move.position).to be('d5')
      end
    end
    context 'when moved vertically' do
      subject(:vertical_move) { described_class.new('a1') }
      it "doesn't change its position" do
        vertical_move.move('a4')
        expect(vertical_move.position).to be('a1')
      end
      it 'returns nil' do
        expect(vertical_move.move('a6')).to be(nil)
      end
    end
    context 'when moved horizontally' do
      subject(:horizontal_move) { described_class.new('b1') }
      it "doesn't change its position" do
        horizontal_move.move('h1')
        expect(horizontal_move.position).to be('b1')
      end
      it 'returns nil' do
        expect(horizontal_move.move('c1')).to be(nil)
      end
    end
    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }
      it "doesn't change its position" do
        immovable_move.move('K0')
        expect(immovable_move.position).to be('K0')
      end
      it 'returns nil' do
        expect(immovable_move.move('K0')).to be(nil)
      end
    end
  end
end
# rubocop: enable Layout/LineLength, Metrics/BlockLength
