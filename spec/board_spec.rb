# frozen_string_literal: true

require_relative '../chess'

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

    context 'when a squares are in bounds' do
      subject(:in_bounds) { described_class.new }

      let(:start_square) { instance_double(Square, position: 'a1', piece:) }
      let(:target_square) { instance_double(Square, position: 'a2', piece: nil) }
      let(:piece) { instance_double(Piece) }

      before do
        in_bounds.board['a1'] = start_square
        in_bounds.board['a2'] = target_square
        allow(start_square).to receive(:piece).and_return(piece)
        allow(start_square).to receive(:vacate).once
        allow(target_square).to receive(:place)
        allow(piece).to receive(:insecure_move).with('a2')
      end

      it 'sends start_square a vacate message' do
        in_bounds.move_piece('a1', 'a2')
        expect(start_square).to have_received(:vacate)
      end

      it 'sends target_square a place message with proper piece' do
        in_bounds.move_piece('a1', 'a2')
        expect(target_square).to have_received(:place).with(piece)
      end

      it 'sends piece a insecure_move message' do
        in_bounds.move_piece('a1', 'a2')
        expect(piece).to have_received(:insecure_move).with('a2')
      end
    end
  end

  describe '#dump_to_fen' do
    subject(:usual_board) { described_class.new }

    before do
      usual_board.setup_from_fen('k7/1R6/8/8/8/8/8/7r')
    end

    it 'returns proper FEN representation' do
      expected = 'k7/1R6/8/8/8/8/8/7r'
      expect(usual_board.dump_to_fen).to eq(expected)
    end
  end

  describe '#copy' do
    subject(:polly_board) { described_class.new }

    before do
      polly_board.setup_from_fen
      polly_board.piece_for('a1').insecure_move('a3')
      polly_board.find('a1').vacate
    end

    it 'returns a new board with all pieces in the same spots' do
      polly_pieces = polly_board.pieces
      molly_board = polly_board.copy
      molly_pieces = molly_board.pieces
      expect(molly_pieces).to eq(polly_pieces)
    end

    it 'has to remember move_history of pieces' do
      polly_pieces = polly_board.pieces
      molly_board = polly_board.copy
      molly_pieces = molly_board.pieces
      expect(molly_pieces).to match_array(polly_pieces)
    end

    it 'gets a deep copy of move_history for pieces' do
      polly_piece = polly_board.piece_for('a1')
      molly_board = polly_board.copy
      molly_piece = molly_board.piece_for('a1')
      expect(molly_piece.move_history).not_to be(polly_piece.move_history)
    end
  end

  describe '#piece_for' do
    subject(:pieceful_board) { described_class.new }

    let(:board_hash) { pieceful_board.board }
    let(:square) { instance_double(Square) }

    before do
      board_hash['a1'] = square
      allow(square).to receive(:piece)
    end

    it 'sends Square a piece message' do
      pieceful_board.piece_for('a1')
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

  describe '#setup_from_fen' do
    subject(:starting_board) { described_class.new }

    let(:board) { starting_board.instance_variable_get(:@board) }

    before do
      starting_board.setup_from_fen
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
        nil_board.setup_from_fen
        expect(factory).not_to have_received(:fen_for).with(integer_as_string, anything)
      end

      it "doesn't create NilPieces on underway setup" do
        nil_board.setup_from_fen('rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R')
        expect(factory).not_to have_received(:fen_for).with(integer_as_string, anything)
      end
    end

    context 'when rows contain empty squares' do
      subject(:sparse_board) { described_class.new }

      let(:coordinate) { Coordinate }

      before do
        notation = '3pP3/8/8/8/8/8/8/8'
        sparse_board.setup_from_fen(notation)
      end

      it 'puts a black Pawn into d8' do
        expect(sparse_board.piece_for('d8')).to be_a(Pawn).and have_attributes(position: coordinate.parse('d8'), colour: 'black')
      end

      it 'puts a white Pawn into e8' do
        expect(sparse_board.piece_for('e8')).to be_a(Pawn).and have_attributes(position: coordinate.parse('e8'), colour: 'white')
      end
    end
  end

  describe '#find_kings' do
    subject(:kingful_board) { described_class.new }

    let(:white_king) { instance_double(King, position: 'a1', colour: 'white') }
    let(:black_king) { instance_double(King, position: 'h8', colour: 'black') }

    before do
      kingful_board.put(white_king, 'a1')
      kingful_board.put(black_king, 'h8')
      allow(white_king).to receive(:real?).and_return(true)
      allow(black_king).to receive(:real?).and_return(true)
      allow(white_king).to receive(:instance_of?).with(King).and_return(King)
      allow(black_king).to receive(:instance_of?).with(King).and_return(King)
    end

    it 'returns both Kings' do
      kings = [white_king, black_king]
      expect(kingful_board.find_kings).to match_array(kings)
    end
  end

  describe '#pieces' do
    subject(:board_and_pieces) { described_class.new }

    let(:piece) { instance_double(Piece, position: 'whatever') }

    before do
      allow(piece).to receive(:real?).and_return(true)
      coordinates = %w[a1 a2 a3]
      coordinates.each do |coordinate|
        board_and_pieces.put(piece, coordinate)
      end
    end

    it 'returns all the pieces on board' do
      proper_pieces = [piece, piece, piece]
      expect(board_and_pieces.pieces).to eq(proper_pieces)
    end
  end

  describe '#vacate' do
    subject(:vacate_board) { Board.new(square_class) }

    let(:square_class) { class_double(Square) }
    let(:square) { instance_double(Square, position: 'a1') }

    before do
      allow(square_class).to receive(:new).and_return(square)
      allow(square).to receive(:vacate).once
    end

    it 'sends Square a vacate message' do
      vacate_board.vacate('a1')
      expect(square).to have_received(:vacate)
    end
  end

  describe '#create_en_passant_pair' do
    subject(:navigate_en_passant) { described_class.new }

    let(:move) { Move.parse('d7d5') }

    before do
      navigate_en_passant.setup_from_fen('rnbqkbnr/ppp1pppp/8/3p4/8/8/PPPPPPPP/RNBQKBNR')
    end

    it 'changes @en_passant_coordinate to the proper coordinate' do
      expect { navigate_en_passant.create_en_passant_pair(move) }.to change(navigate_en_passant, :en_passant_coordinate).from(nil).to(move.target.up)
    end
  end

  describe '#clear_en_passant_pair' do
    subject(:clear_en_passant) { described_class.new }

    let(:move) { Move.parse('g7g5') }

    before do
      clear_en_passant.setup_from_fen('rnbqkbnr/pppppp1p/8/6p1/8/8/PPPPPPPP/RNBQKBNR')
      clear_en_passant.create_en_passant_pair(move)
    end

    it 'changes @en_passant_coordinate to nil' do
      expect { clear_en_passant.clear_en_passant_pair }.to change(clear_en_passant, :en_passant_coordinate).to(nil)
    end
  end

  describe '#record_en_passant_coordinate' do
    context 'when there is a coordinate to be recorded' do
      subject(:en_passant) { described_class.new }

      before do
        en_passant.instance_variable_set(:@en_passant_pair, EnPassantPair.new(nil, Coordinate.parse('a3')))
      end

      it 'returns a proper string of it' do
        string = 'a3'
        expect(en_passant.record_en_passant_coordinate).to eq(string)
      end
    end

    context 'when there is no coordiante to be recorded' do
      subject(:no_en_passant) { described_class.new }

      before do
        no_en_passant.instance_variable_set(:@en_passant_pair, EnPassantPair.new(nil, nil))
      end

      it 'returns a proper string of it' do
        string = '-'
        expect(no_en_passant.record_en_passant_coordinate).to eq(string)
      end
    end
  end

  describe '#promoteable?' do
    context 'when piece at the coordinate is promoteable' do
      subject(:promoteable_board) { described_class.new }

      before do
        promoteable_board.setup_from_fen('P3k3/4p3/8/8/8/8/4P3/4K3')
      end

      it 'returns true' do
        coordinate = 'a8'
        expect(promoteable_board.promoteable?(coordinate)).to be true
      end
    end

    context 'when piece at the coordinate is not promoteable' do
      subject(:nonpromoteable_board) { described_class.new }

      before do
        nonpromoteable_board.setup_from_fen('R3k3/4p3/8/8/8/8/4P3/4K3')
      end

      it 'returns false' do
        coordinate = 'a8'
        expect(nonpromoteable_board.promoteable?(coordinate)).to be false
      end
    end
  end

  describe '#king_for' do
    subject(:looking_for_a_king) { described_class.new }

    let(:white_king) { instance_double(King, position: 'a1', colour: 'white', real?: true) }
    let(:black_king) { instance_double(King, position: 'a2', colour: 'black', real?: true) }
    let(:white_piece) { instance_double(Piece, position: 'a3', colour: 'white', real?: true) }

    before do
      allow(white_king).to receive(:instance_of?).with(King).and_return true
      allow(black_king).to receive(:instance_of?).with(King).and_return true
      allow(white_piece).to receive(:ally?).with(white_king).and_return true
      allow(white_piece).to receive(:ally?).with(black_king).and_return false
      looking_for_a_king.put(white_king, 'a1')
      looking_for_a_king.put(black_king, 'a2')
      looking_for_a_king.put(white_piece, 'a3')
    end

    it 'returns allied King of a piece' do
      coordinate = 'a3'
      expect(looking_for_a_king.king_for(coordinate)).to eq(white_king)
    end
  end

  describe '#queenside_castling_rights?' do
    context 'when it has those rights' do
      subject(:queenside_castling) { described_class.new }

      let(:king) { instance_double(King, can_castle?: true, real?: true, colour: 'white') }
      let(:left_rook) { instance_double(Rook, can_castle?: true, real?: true, colour: 'white', position: Coordinate.parse('a1')) }
      let(:right_rook) { instance_double(Rook, can_castle?: true, real?: true, colour: 'white', position: Coordinate.parse('h1')) }

      before do
        allow(king).to receive(:is_a?).with(King).and_return(true)
        allow(king).to receive(:is_a?).with(Rook).and_return(false)
        allow(left_rook).to receive(:is_a?).with(King).and_return(false)
        allow(right_rook).to receive(:is_a?).with(King).and_return(false)
        allow(left_rook).to receive(:is_a?).with(Rook).and_return(true)
        allow(right_rook).to receive(:is_a?).with(Rook).and_return(true)
        queenside_castling.put(king, 'e1')
        queenside_castling.put(left_rook, 'a1')
        queenside_castling.put(right_rook, 'h1')
      end

      it 'returns true' do
        colour = 'white'
        expect(queenside_castling.queenside_castling_rights?(colour)).to be true
      end
    end

    context 'when it does not have those rights because of missing queenside rook' do
      subject(:queenside_castling) { described_class.new }

      let(:king) { instance_double(King, can_castle?: true, real?: true, colour: 'black') }
      let(:right_rook) { instance_double(Rook, can_castle?: true, real?: true, colour: 'black', position: Coordinate.parse('h1')) }

      before do
        allow(king).to receive(:is_a?).with(King).and_return(true)
        allow(king).to receive(:is_a?).with(Rook).and_return(false)
        allow(right_rook).to receive(:is_a?).with(King).and_return(false)
        allow(right_rook).to receive(:is_a?).with(Rook).and_return(true)
        queenside_castling.put(king, 'e8')
        queenside_castling.put(right_rook, 'h1')
      end

      it 'returns false' do
        colour = 'black'
        expect(queenside_castling.queenside_castling_rights?(colour)).to be false
      end
    end

    context 'when it does not have those rights because of loaded state' do
      subject(:loaded_queenside) { described_class.new }

      before do
        loaded_queenside.load_castling_rights('Kk')
      end

      it 'returns false' do
        colour = 'black'
        expect(loaded_queenside.queenside_castling_rights?(colour)).to be false
      end
    end
  end

  describe '#kingside_castling_rights?' do
    context 'when it has those rights' do
      subject(:kingside_castling) { described_class.new }

      let(:king) { instance_double(King, can_castle?: true, real?: true, colour: 'white') }
      let(:left_rook) { instance_double(Rook, can_castle?: true, real?: true, colour: 'white', position: Coordinate.parse('a1')) }
      let(:right_rook) { instance_double(Rook, can_castle?: true, real?: true, colour: 'white', position: Coordinate.parse('h1')) }

      before do
        allow(king).to receive(:is_a?).with(King).and_return(true)
        allow(king).to receive(:is_a?).with(Rook).and_return(false)
        allow(left_rook).to receive(:is_a?).with(King).and_return(false)
        allow(right_rook).to receive(:is_a?).with(King).and_return(false)
        allow(left_rook).to receive(:is_a?).with(Rook).and_return(true)
        allow(right_rook).to receive(:is_a?).with(Rook).and_return(true)
        kingside_castling.put(king, 'e1')
        kingside_castling.put(left_rook, 'a1')
        kingside_castling.put(right_rook, 'h1')
      end

      it 'returns true' do
        colour = 'white'
        expect(kingside_castling.kingside_castling_rights?(colour)).to be true
      end
    end

    context 'when it does not have those rights because of missing kingside rook' do
      subject(:kingside_castling) { described_class.new }

      let(:king) { instance_double(King, can_castle?: true, real?: true, colour: 'black') }
      let(:left_rook) { instance_double(Rook, can_castle?: true, real?: true, colour: 'black', position: Coordinate.parse('a1')) }

      before do
        allow(king).to receive(:is_a?).with(King).and_return(true)
        allow(king).to receive(:is_a?).with(Rook).and_return(false)
        allow(left_rook).to receive(:is_a?).with(King).and_return(false)
        allow(left_rook).to receive(:is_a?).with(Rook).and_return(true)
        kingside_castling.put(king, 'e1')
        kingside_castling.put(left_rook, 'a1')
      end

      it 'returns false' do
        colour = 'black'
        expect(kingside_castling.kingside_castling_rights?(colour)).to be false
      end
    end

    context 'when it does not have those rights because of loaded state' do
      subject(:loaded_kingside) { described_class.new }

      before do
        loaded_kingside.load_castling_rights('kQq')
      end

      it 'returns false' do
        colour = 'white'
        expect(loaded_kingside.kingside_castling_rights?(colour)).to be false
      end
    end
  end

  describe '#record_castling_rights' do
    context 'when everyone has full castling rights' do
      subject(:full_castling_rights) { described_class.new }

      before do
        full_castling_rights.setup_from_fen
      end

      it 'returns a proper string' do
        string = 'KQkq'
        expect(full_castling_rights.record_castling_rights).to eq(string)
      end
    end

    context 'when only black has castling rights' do
      subject(:black_castling_rights) { described_class.new }

      before do
        black_castling_rights.setup_from_fen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/1NBQKBN1')
      end

      it 'returns a proper string' do
        string = 'kq'
        expect(black_castling_rights.record_castling_rights).to eq(string)
      end
    end

    context 'when no one has castling rights' do
      subject(:no_castling_rights) { described_class.new }

      before do
        no_castling_rights.setup_from_fen('1nbqkbn1/pppppppp/8/8/8/8/PPPPPPPP/1NBQKBN1')
      end

      it 'returns a proper string' do
        string = '-'
        expect(no_castling_rights.record_castling_rights).to eq(string)
      end
    end
  end
end

describe Square do
  describe '#place' do
    subject(:empty_square) { described_class.new('c4') }

    let(:piece) { instance_double(Piece) }

    before do
      allow(piece).to receive(:colour).and_return('white')
    end

    it 'stores the piece in @piece' do
      expect { empty_square.place(piece) }.to change(empty_square, :piece)
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
