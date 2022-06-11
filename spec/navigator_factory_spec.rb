# frozen_string_literal: true

require_relative '../lib/navigator_factory'
require_relative '../lib/board'
require_relative '../lib/piece'
require_relative '../lib/piece/rook'
require_relative '../lib/piece/bishop'
require_relative '../lib/piece/queen'
require_relative '../lib/piece/king'
require_relative '../lib/piece/knight'
require_relative '../lib/piece/pawn'

# rubocop: disable RSpec/MultipleMemoizedHelpers
describe NavigatorFactory do
  let(:coordinate) { Coordinate }

  describe '@for' do
    let(:factory) { described_class }
    let(:board) { instance_double(Board) }
    let(:rook) { instance_double(Rook) }
    let(:bishop) { instance_double(Bishop) }
    let(:queen) { instance_double(Queen) }
    let(:king) { instance_double(King) }
    let(:knight) { instance_double(Knight) }
    let(:pawn) { instance_double(Pawn) }

    before do
      allow(rook).to receive(:class).and_return(Rook)
      allow(bishop).to receive(:class).and_return(Bishop)
      allow(queen).to receive(:class).and_return(Queen)
      allow(king).to receive(:class).and_return(King)
      allow(knight).to receive(:class).and_return(Knight)
      allow(pawn).to receive(:class).and_return(Pawn)
    end

    it 'creates a PawnNavigator instance' do
      expect(factory.for(board, pawn)).to be_a(PawnNavigator)
    end

    it 'creates a RookNavigator instance' do
      expect(factory.for(board, rook)).to be_a(RookNavigator)
    end

    it 'creates a KnightNavigator instance' do
      expect(factory.for(board, knight)).to be_a(KnightNavigator)
    end

    it 'creates a BishopNavigator instance' do
      expect(factory.for(board, bishop)).to be_a(BishopNavigator)
    end

    it 'creates a QueenNavigator instance' do
      expect(factory.for(board, queen)).to be_a(QueenNavigator)
    end

    it 'creates a KingNavigator instance' do
      expect(factory.for(board, king)).to be_a(KingNavigator)
    end

    it 'defaults to a PieceNavigator instance' do
      expect(factory.for(board, 'Unicorn')).to be_a(PieceNavigator)
    end
  end
end
# rubocop: enable RSpec/MultipleMemoizedHelpers
