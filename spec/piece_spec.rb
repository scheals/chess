# frozen_string_literal: true

require_relative '../lib/piece_factory'
require_relative '../lib/piece'
require_relative '../lib/piece/rook'
require_relative '../lib/piece/bishop'
require_relative '../lib/piece/queen'
require_relative '../lib/piece/king'
require_relative '../lib/piece/knight'
require_relative '../lib/piece/pawn'
require_relative '../lib/piece/nil_piece'

# rubocop: disable Layout/LineLength
describe Piece do
  describe 'real?' do
    subject(:real_piece) { described_class.new('a1') }

    it 'always returns true' do
      expect(real_piece.real?).to be true
    end
  end
end

describe NilPiece do
  describe 'real?' do
    subject(:false_piece) { described_class.new('a1') }

    it 'always returns false' do
      expect(false_piece.real?).to be false
    end
  end
end

describe King do
  describe '#move' do
    context 'when moved vertically by one tile' do
      subject(:vertical_move) { described_class.new('a1') }

      it 'changes its position' do
        vertical_move.move('a2')
        expect(vertical_move.position).to be('a2')
      end

      it 'does not move further than one tile' do
        expect { vertical_move.move('a6') }.not_to change(vertical_move, :position)
      end
    end

    context 'when moved horizontally by one tile' do
      subject(:horizontal_move) { described_class.new('b1') }

      it 'changes its position' do
        horizontal_move.move('c1')
        expect(horizontal_move.position).to be('c1')
      end

      it 'does not move further than one tile' do
        expect { horizontal_move.move('h1') }.not_to change(horizontal_move, :position)
      end
    end

    context 'when moved diagonally by one tile' do
      subject(:diagonal_move) { described_class.new('c4') }

      it 'changes its position' do
        diagonal_move.move('d5')
        expect(diagonal_move.position).to be('d5')
      end

      it 'does not move further than one tile' do
        expect { diagonal_move.move('e6') }.not_to change(diagonal_move, :position)
      end
    end

    context 'when told to make an illegal move' do
      subject(:illegal_move) { described_class.new('c5') }

      it 'does not change its position' do
        expect { illegal_move.move('a6') }.not_to change(illegal_move, :position)
      end
    end

    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }

      it "doesn't change its position" do
        expect { immovable_move.move('K0') }.not_to change(immovable_move, :position)
      end

      it 'returns nil' do
        expect(immovable_move.move('K0')).to be_nil
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

    context 'when told to make an invalid move' do
      subject(:invalid_move) { described_class.new('d4') }

      it "doesn't change its position" do
        expect { invalid_move.move('c7') }.not_to change(invalid_move, :position)
      end

      it 'returns nil' do
        expect(invalid_move.move('c7')).to be_nil
      end
    end

    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }

      it "doesn't change its position" do
        expect { immovable_move.move('K0') }.not_to change(immovable_move, :position)
      end

      it 'returns nil' do
        expect(immovable_move.move('K0')).to be_nil
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
        expect { diagonal_move.move('d5') }.not_to change(diagonal_move, :position)
      end

      it 'returns nil' do
        expect(diagonal_move.move('b3')).to be_nil
      end
    end

    context 'when told to make an invalid move' do
      subject(:invalid_move) { described_class.new('d4') }

      it "doesn't change its position" do
        expect { invalid_move.move('c7') }.not_to change(invalid_move, :position)
      end

      it 'returns nil' do
        expect(invalid_move.move('c7')).to be_nil
      end
    end

    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }

      it "doesn't change its position" do
        expect { immovable_move.move('K0') }.not_to change(immovable_move, :position)
      end

      it 'returns nil' do
        expect(immovable_move.move('K0')).to be_nil
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
        expect { vertical_move.move('a4') }.not_to change(vertical_move, :position)
      end

      it 'returns nil' do
        expect(vertical_move.move('a6')).to be_nil
      end
    end

    context 'when moved horizontally' do
      subject(:horizontal_move) { described_class.new('b1') }

      it "doesn't change its position" do
        expect { horizontal_move.move('h1') }.not_to change(horizontal_move, :position)
      end

      it 'returns nil' do
        expect(horizontal_move.move('c1')).to be_nil
      end
    end

    context 'when told to make an invalid move' do
      subject(:invalid_move) { described_class.new('d4') }

      it "doesn't change its position" do
        expect { invalid_move.move('c7') }.not_to change(invalid_move, :position)
      end

      it 'returns nil' do
        expect(invalid_move.move('c7')).to be_nil
      end
    end

    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }

      it "doesn't change its position" do
        expect { immovable_move.move('K0') }.not_to change(immovable_move, :position)
      end

      it 'returns nil' do
        expect(immovable_move.move('K0')).to be_nil
      end
    end
  end
end

describe Knight do
  describe '#move' do
    subject(:centre_position) { described_class.new('d4') }

    context 'when moved twice left then up once' do
      it 'changes its position' do
        centre_position.move('b5')
        expect(centre_position.position).to be('b5')
      end
    end

    context 'when moved twice left then down once' do
      it 'changes its position' do
        centre_position.move('b3')
        expect(centre_position.position).to be('b3')
      end
    end

    context 'when moved twice right then up once' do
      it 'changes its position' do
        centre_position.move('f5')
        expect(centre_position.position).to be('f5')
      end
    end

    context 'when moved twice right then down once' do
      it 'changes its position' do
        centre_position.move('f3')
        expect(centre_position.position).to be('f3')
      end
    end

    context 'when moved twice up then left once' do
      it 'changes its position' do
        centre_position.move('c6')
        expect(centre_position.position).to be('c6')
      end
    end

    context 'when moved twice up then right once' do
      it 'changes its position' do
        centre_position.move('e6')
        expect(centre_position.position).to be('e6')
      end
    end

    context 'when moved twice down then left once' do
      it 'changes its position' do
        centre_position.move('c2')
        expect(centre_position.position).to be('c2')
      end
    end

    context 'when moved twice down then right once' do
      it 'changes its position' do
        centre_position.move('e2')
        expect(centre_position.position).to be('e2')
      end
    end

    context 'when told to move on its own position' do
      subject(:immovable_move) { described_class.new('K0') }

      it "doesn't change its position" do
        expect { immovable_move.move('K0') }.not_to change(immovable_move, :position)
      end

      it 'returns nil' do
        expect(immovable_move.move('K0')).to be_nil
      end
    end
  end
end

describe Pawn do
  describe '#move' do
    context 'when Pawn is white' do
      subject(:white_pawn) { described_class.new('c3', colour: 'white') }

      it 'can only go up one space at a time' do
        white_pawn.move('c4')
        expect(white_pawn.position).to be('c4')
      end

      it 'does not make an illegal move' do
        expect { white_pawn.move('d5') }.not_to change(white_pawn, :position)
      end

      context 'when it has not moved yet' do
        subject(:white_double) { described_class.new('b2', colour: 'white') }

        it 'can move two spaces up at once' do
          expect { white_double.move('b4') }.to change(white_double, :position).from('b2').to('b4')
        end
      end

      context 'when there is a piece to be taken diagonally' do
        subject(:white_take) { described_class.new('f4', colour: 'white') }

        let(:occupied_space) { instance_double(Square, coordinates: 'e5') }

        before do
          allow(occupied_space).to receive(:occupied?).and_return(true)
        end

        it 'can move one space up diagonally' do
          space = occupied_space.coordinates
          white_take.move(space)
          expect(white_take.position).to be('e5')
        end
      end
    end

    context 'when Pawn is black' do
      subject(:black_pawn) { described_class.new('e5', colour: 'black') }

      it 'can only go down one space at a time' do
        black_pawn.move('e4')
        expect(black_pawn.position).to be('e4')
      end

      it 'does not make an illegal move' do
        expect { black_pawn.move('f3') }.not_to change(black_pawn, :position)
      end

      context 'when it has not moved yet' do
        subject(:black_double) { described_class.new('e7', colour: 'black') }

        it 'can move two spaces down at once' do
          expect { black_double.move('e5') }.to change(black_double, :position).from('e7').to('e5')
        end
      end

      context 'when there is a piece to be taken diagonally' do
        subject(:black_take) { described_class.new('c5', colour: 'black') }

        let(:occupied_space) { instance_double(Square, coordinates: 'd4') }

        before do
          allow(occupied_space).to receive(:occupied?).and_return(true)
        end

        it 'can move one space down diagonally' do
          space = occupied_space.coordinates
          black_take.move(space)
          expect(black_take.position).to be('d4')
        end
      end
    end
  end
end

describe PieceFactory do
  describe '@for' do
    let(:factory) { described_class }

    it 'creates a Pawn instance' do
      expect(factory.for('Pawn', position: 'a2')).to be_a(Pawn)
    end

    it 'creates a Rook instance' do
      expect(factory.for('Rook', position: 'a1')).to be_a(Rook)
    end

    it 'creates a Knight instance' do
      expect(factory.for('Knight', position: 'b1')).to be_a(Knight)
    end

    it 'creates a Bishop instance' do
      expect(factory.for('Bishop', position: 'c1')).to be_a(Bishop)
    end

    it 'creates a Queen instance' do
      expect(factory.for('Queen', position: 'd1')).to be_a(Queen)
    end

    it 'creates a King instance' do
      expect(factory.for('King', position: 'e1')).to be_a(King)
    end

    it 'defaults to a Piece instance' do
      expect(factory.for('Unicorn', position: 'L4')).to be_a(Piece)
    end

    context 'when given a colour' do
      it 'creates a piece with the right colour' do
        piece = 'Pawn'
        expect(factory.for(piece, colour: 'red', position: 'B9')).to be_a(Pawn).and have_attributes(colour: 'red', position: 'B9')
      end
    end
  end
end
# rubocop: enable Layout/LineLength
