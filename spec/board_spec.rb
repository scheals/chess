# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/square'

# rubocop: disable Metrics/BlockLength,Layout/LineLength, Lint/AmbiguousBlockAssociation
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

  describe '#create_piece' do
    subject(:board) { described_class.new }
    let(:factory) { board.instance_variable_get(:@factory) }
    before do
      allow(factory).to receive(:for).with('Pawn', colour: 'white', position: 'a2')
    end
    it 'sends factory a @for message' do
      expect(factory).to receive(:for).with('Pawn', colour: 'white', position: 'a2')
      board.create_piece('Pawn', colour: 'white', position: 'a2')
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
        allow(piece).to receive(:real?).and_return(true)
      end
      it 'returns nil' do
        expect(full_board.put(piece, 'a2')).to be_nil
      end
    end
  end

  describe '#in_bounds?' do
    context 'when coordinates are in bound' do
      subject(:in_bounds) { described_class.new }
      it 'returns true' do
        ordinary_coordinate = 'f5'
        expect(in_bounds.in_bounds?(ordinary_coordinate)).to be true
      end
    end
    context 'when coordinates are not in bound' do
      subject(:not_in_bounds) { described_class.new }
      it 'returns false' do
        extraordinary_coordinate = 'Pluto'
        expect(not_in_bounds.in_bounds?(extraordinary_coordinate)).to be false
      end
    end
  end

  describe '#move_piece' do
    context 'when a square is out of bounds' do
      subject(:out_of_bounds) { described_class.new }
      it 'returns nil' do
        reachable_square = 'a1'
        unreachable_square = 'Aquarius'
        expect(out_of_bounds.move_piece(reachable_square, unreachable_square)).to be_nil
      end
    end
  end

  describe '#find_piece' do
    subject(:pieceful_board) { described_class.new }
    it 'sends Square a piece message' do
      a1_square = pieceful_board.board['a1']
      expect(a1_square).to receive(:piece)
      pieceful_board.find_piece('a1')
    end
  end

  describe '#row' do
    context 'when given 2 as an argument' do
      subject(:row_board) { described_class.new }
      it 'returns a hash of Squares from the second row' do
        expect(row_board.row(2)).to include(
          'a2' => be_a(Square),
          'b2' => be_a(Square),
          'c2' => be_a(Square),
          'd2' => be_a(Square),
          'e2' => be_a(Square),
          'f2' => be_a(Square),
          'g2' => be_a(Square),
          'h2' => be_a(Square)
        )
      end
    end
  end

  describe '#setup' do
    subject(:starting_board) { described_class.new }
    let(:board) { starting_board.instance_variable_get(:@board) }
    before do
      starting_board.setup
    end
    it 'puts black Rook into a8' do
      starting_square = board['a8']
      expect(starting_square.piece).to be_a(Rook).and have_attributes(colour: 'black')
    end
    it 'puts black Rook into h8' do
      starting_square = board['h8']
      expect(starting_square.piece).to be_a(Rook).and have_attributes(colour: 'black')
    end
    it 'puts black Knight into b8' do
      starting_square = board['b8']
      expect(starting_square.piece).to be_a(Knight).and have_attributes(colour: 'black')
    end
    it 'puts black Knight into g8' do
      starting_square = board['g8']
      expect(starting_square.piece).to be_a(Knight).and have_attributes(colour: 'black')
    end
    it 'puts black Bishop into c8' do
      starting_square = board['c8']
      expect(starting_square.piece).to be_a(Bishop).and have_attributes(colour: 'black')
    end
    it 'puts black Bishop into f8' do
      starting_square = board['f8']
      expect(starting_square.piece).to be_a(Bishop).and have_attributes(colour: 'black')
    end
    it 'puts black Queen into d8' do
      starting_square = board['d8']
      expect(starting_square.piece).to be_a(Queen).and have_attributes(colour: 'black')
    end
    it 'puts black King into e8' do
      starting_square = board['e8']
      expect(starting_square.piece).to be_a(King).and have_attributes(colour: 'black')
    end
    it 'puts black Pawns into row 7' do
      starting_row_squares = starting_board.row(7).values
      starting_row_pieces = starting_row_squares.map(&:piece)
      expect(starting_row_pieces).to all(be_a(Pawn).and(have_attributes(colour: 'black')))
    end
    it 'puts white Rook into a1' do
      starting_square = board['a1']
      expect(starting_square.piece).to be_a(Rook).and have_attributes(colour: 'white')
    end
    it 'puts white Rook into h1' do
      starting_square = board['h1']
      expect(starting_square.piece).to be_a(Rook).and have_attributes(colour: 'white')
    end
    it 'puts white Knight into b1' do
      starting_square = board['b1']
      expect(starting_square.piece).to be_a(Knight).and have_attributes(colour: 'white')
    end
    it 'puts white Knight into g1' do
      starting_square = board['g1']
      expect(starting_square.piece).to be_a(Knight).and have_attributes(colour: 'white')
    end
    it 'puts white Bishop into c1' do
      starting_square = board['c1']
      expect(starting_square.piece).to be_a(Bishop).and have_attributes(colour: 'white')
    end
    it 'puts white Bishop into f1' do
      starting_square = board['f1']
      expect(starting_square.piece).to be_a(Bishop).and have_attributes(colour: 'white')
    end
    it 'puts white Queen into d1' do
      starting_square = board['d1']
      expect(starting_square.piece).to be_a(Queen).and have_attributes(colour: 'white')
    end
    it 'puts white King into e1' do
      starting_square = board['e1']
      expect(starting_square.piece).to be_a(King).and have_attributes(colour: 'white')
    end
    it 'puts white Pawns into row 2' do
      starting_row_squares = starting_board.row(2).values
      starting_row_pieces = starting_row_squares.map(&:piece)
      expect(starting_row_pieces).to all(be_a(Pawn).and(have_attributes(colour: 'white')))
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
        allow(piece).to receive(:real?).and_return(true)
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
        allow(piece).to receive(:real?).and_return(true)
      end
      it 'changes @piece into a NilPiece' do
        expect { occupied_square.vacate }.to change { occupied_square.instance_variable_get(:@piece) }.from(piece).to be_a(NilPiece)
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
        allow(piece).to receive(:real?).and_return(true)
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
# rubocop: enable Metrics/BlockLength, Layout/LineLength, Lint/AmbiguousBlockAssociation
