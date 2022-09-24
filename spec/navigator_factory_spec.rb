# frozen_string_literal: true

require_relative '../chess'

# rubocop: disable RSpec/MultipleMemoizedHelpers
describe NavigatorFactory do
  let(:coordinate) { Coordinate }

  describe '@for' do
    let(:factory) { described_class }
    let(:board_navigator) { instance_double(BoardNavigator, board:) }
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
      expect(factory.for(board_navigator, pawn)).to be_a(PawnNavigator)
    end

    it 'creates a RookNavigator instance' do
      expect(factory.for(board_navigator, rook)).to be_a(RookNavigator)
    end

    it 'creates a KnightNavigator instance' do
      expect(factory.for(board_navigator, knight)).to be_a(KnightNavigator)
    end

    it 'creates a BishopNavigator instance' do
      expect(factory.for(board_navigator, bishop)).to be_a(BishopNavigator)
    end

    it 'creates a QueenNavigator instance' do
      expect(factory.for(board_navigator, queen)).to be_a(QueenNavigator)
    end

    it 'creates a KingNavigator instance' do
      expect(factory.for(board_navigator, king)).to be_a(KingNavigator)
    end

    it 'defaults to a PieceNavigator instance' do
      expect(factory.for(board_navigator, 'Unicorn')).to be_a(PieceNavigator)
    end
  end
end
# rubocop: enable RSpec/MultipleMemoizedHelpers
