# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/square'

# rubocop: disable Layout/LineLength
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
    subject(:board) { described_class.new(square, factory) }

    let(:square) { class_double(Square) }
    let(:factory) { class_double(PieceFactory) }

    before do
      allow(square).to receive(:new)
      allow(factory).to receive(:for).with('Pawn', colour: 'white', position: 'a2')
    end

    it 'sends factory a @for message' do
      board.create_piece('Pawn', colour: 'white', position: 'a2')
      expect(factory).to have_received(:for).with('Pawn', colour: 'white', position: 'a2')
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
      let(:empty_square) { instance_double(Square) }
      let(:board_hash) { empty_board.board }

      before do
        board_hash['d6'] = empty_square
        allow(empty_square).to receive(:place).with(piece)
      end

      it 'sends that square a #place message' do
        empty_board.put(piece, 'd6')
        expect(empty_square).to have_received(:place)
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

  describe '#dump_to_fen' do
    subject(:usual_board) { described_class.new }

    before do
      usual_board.setup('k7/1R6/8/8/8/8/8/7r')
    end

    it 'returns a string of FEN-ish representation of the board usable by #setup' do
      expected = 'k1111111/1R111111/11111111/11111111/11111111/11111111/11111111/1111111r/'
      expect(usual_board.dump_to_fen).to eq(expected)
    end
  end

  describe '#copy' do
    subject(:polly_board) { described_class.new }

    before do
      polly_board.setup
      polly_board.find_piece('a1').move('a3')
      polly_board.find('a1').vacate
    end

    it 'returns a new board with all pieces in the same spots' do
      polly_pieces = polly_board.board.values.map(&:piece)
      molly_board = polly_board.copy
      molly_pieces = molly_board.board.values.map(&:piece)
      expect(molly_pieces).to eq(polly_pieces)
    end

    it 'has to remember move_history of pieces' do
      polly_pieces = polly_board.board.values.map(&:piece)
      molly_board = polly_board.copy
      molly_pieces = molly_board.board.values.map(&:piece)
      expect(molly_pieces).to match_array(polly_pieces)
    end
  end

  describe '#find_piece' do
    subject(:pieceful_board) { described_class.new }

    let(:board_hash) { pieceful_board.board }
    let(:square) { instance_double(Square) }

    before do
      board_hash['a1'] = square
      allow(square).to receive(:piece)
    end

    it 'sends Square a piece message' do
      pieceful_board.find_piece('a1')
      expect(square).to have_received(:piece)
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

    context 'when dealing with empty squares' do
      subject(:nil_board) { described_class.new(square, factory) }

      let(:square) { Square }
      let(:factory) { class_double(PieceFactory) }

      RSpec::Matchers.define :integer_as_string do
        match { |actual| actual.to_i.positive? }
      end

      before do
        allow(factory).to receive(:fen_for)
      end

      it "doesn't create NilPieces on regular setup" do
        nil_board.setup
        expect(factory).not_to have_received(:fen_for).with(integer_as_string, anything)
      end

      it "doesn't create NilPieces on underway setup" do
        nil_board.setup('rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R')
        expect(factory).not_to have_received(:fen_for).with(integer_as_string, anything)
      end
    end

    context 'when rows contain empty squares' do
      subject(:sparse_board) { described_class.new }

      let(:coordinate) { Coordinate }

      before do
        notation = '3pP3/8/8/8/8/8/8/8'
        sparse_board.setup(notation)
      end

      it 'puts a black Pawn into d8' do
        expect(sparse_board.find_piece('d8')).to be_a(Pawn).and have_attributes(position: coordinate.parse('d8'), colour: 'black')
      end

      it 'puts a white Pawn into e8' do
        expect(sparse_board.find_piece('e8')).to be_a(Pawn).and have_attributes(position: coordinate.parse('e8'), colour: 'white')
      end
    end
  end
end

describe Square do
  describe '#place' do
    context 'when square is not occupied by a piece' do
      subject(:empty_square) { described_class.new('c4') }

      let(:piece) { instance_double(Piece) }

      before do
        allow(piece).to receive(:colour).and_return('white')
      end

      it 'stores the piece in @piece' do
        expect { empty_square.place(piece) }.to change(empty_square, :piece)
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
        expect { full_square.place(another_piece) }.not_to change(full_square, :piece)
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
        allow(piece).to receive(:colour).and_return('white')
        occupied_square.place(piece)
        allow(piece).to receive(:real?).and_return(true)
      end

      it 'changes @piece into a NilPiece' do
        occupied_square.vacate
        expect(occupied_square.piece).to be_a(NilPiece)
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
# rubocop: enable Layout/LineLength
