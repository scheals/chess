# frozen_string_literal: true

require_relative '../lib/rook'
require_relative '../lib/bishop'
require_relative '../lib/piece'
require_relative '../lib/queen'
require_relative '../lib/king'

# rubocop: disable Layout/LineLength, Metrics/BlockLength, Lint/AmbiguousBlockAssociation
describe King do
  describe '#move' do
    context 'when moved vertically by one tile' do
      subject(:vertical_move) { described_class.new('a1') }
      it 'changes its position' do
        vertical_move.move('a2')
        expect(vertical_move.position).to be('a2')
      end
      it 'does not move further than one tile' do
        expect{ vertical_move.move('a6') }.to_not change { vertical_move.position }
      end
    end
    context 'when moved horizontally by one tile' do
      subject(:horizontal_move) { described_class.new('b1') }
      it 'changes its position' do
        horizontal_move.move('c1')
        expect(horizontal_move.position).to be('c1')
      end
      it 'does not move further than one tile' do
        expect{ horizontal_move.move('h1') }.to_not change { horizontal_move.position }
      end
    end
    context 'when moved diagonally by one tile' do
      subject(:diagonal_move) { described_class.new('c4') }
      it 'changes its position' do
        diagonal_move.move('d5')
        expect(diagonal_move.position).to be('d5')
      end
      it 'does not move further than one tile' do
        expect{ diagonal_move.move('e6') }.to_not change { diagonal_move.position }
      end
    end
    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }
      it "doesn't change its position" do
        expect { immovable_move.move('K0') }.to_not change { immovable_move.position }
      end
      it 'returns nil' do
        expect(immovable_move.move('K0')).to be(nil)
      end
    end
  end
end

describe Queen do
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
      it 'changes its position' do
        diagonal_move.move('d5')
        expect(diagonal_move.position).to be('d5')
      end
    end
    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }
      it "doesn't change its position" do
        expect { immovable_move.move('K0') }.to_not change { immovable_move.position }
      end
      it 'returns nil' do
        expect(immovable_move.move('K0')).to be(nil)
      end
    end
  end
end

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
        expect { diagonal_move.move('d5') }.to_not change { diagonal_move.position }
      end
      it 'returns nil' do
        expect(diagonal_move.move('b3')).to be(nil)
      end
    end
    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }
      it "doesn't change its position" do
        expect { immovable_move.move('K0') }.to_not change { immovable_move.position }
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
        expect { vertical_move.move('a4') }.to_not change { vertical_move.position }
      end
      it 'returns nil' do
        expect(vertical_move.move('a6')).to be(nil)
      end
    end
    context 'when moved horizontally' do
      subject(:horizontal_move) { described_class.new('b1') }
      it "doesn't change its position" do
        expect { horizontal_move.move('h1') }.to_not change { horizontal_move.position }
      end
      it 'returns nil' do
        expect(horizontal_move.move('c1')).to be(nil)
      end
    end
    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }
      it "doesn't change its position" do
        expect { immovable_move.move('K0') }.to_not change { immovable_move.position }
      end
      it 'returns nil' do
        expect(immovable_move.move('K0')).to be(nil)
      end
    end
  end
end
# rubocop: enable Layout/LineLength, Metrics/BlockLength, Lint/AmbiguousBlockAssociation
