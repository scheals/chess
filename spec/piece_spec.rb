# frozen_string_literal: true

require_relative '../lib/rook'

describe Rook do
  describe '#move' do
    context 'when moved horizontally' do
      subject(:horizontal_move) { described_class.new('a1') }
      it 'changes its position' do
        horizontal_move.move('a4')
        expect(horizontal_move.position).to be('a4')
      end
    end
  end
end
