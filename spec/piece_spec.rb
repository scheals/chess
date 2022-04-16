# frozen_string_literal: true

require_relative '../lib/rook'

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
        horizontal_move.move('b5')
        expect(horizontal_move.position).to be('b5')
      end
    end
  end
end
