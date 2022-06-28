# frozen_string_literal: true

require_relative '../lib/piece_navigator'
require_relative '../lib/navigator/bishop_navigator'
require_relative '../lib/navigator/pawn_navigator'
require_relative '../lib/navigator/rook_navigator'
require_relative '../lib/navigator/knight_navigator'
require_relative '../lib/navigator/queen_navigator'
require_relative '../lib/navigator/king_navigator'
require_relative '../lib/board'

describe PieceNavigator do
  describe '#occupied_coordinates' do
    subject(:navigate_collison) { described_class.new(board, queen) }

    let(:board) { Board.new }
    let(:queen) { Queen.new('d4') }

    before do
      board.setup
      board.put(queen, 'd4')
    end

    it 'returns an array of occupied squares' do
      expect(navigate_collison.occupied_coordinates).to contain_exactly('d1', 'd2', 'd7', 'd8',
                                                                        'a1', 'b2', 'g7', 'h8',
                                                                        'g1', 'f2', 'a7')
    end
  end

  describe '#allied_coordinates' do
    subject(:navigate_allies) { described_class.new(board, white_rook) }

    let(:board) { Board.new }
    let(:white_rook) { board.find_piece('a1') }

    before do
      board.setup
    end

    it 'returns an array of squares that allied pieces are on in range of the piece' do
      expect(navigate_allies.allied_coordinates).to contain_exactly('a2',
                                                                    'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1')
    end
  end

  describe '#enemy_coordinates' do
    subject(:navigate_enemies) { described_class.new(board, black_rook) }

    let(:board) { Board.new }
    let(:black_rook) { Rook.new('f4', colour: 'black') }

    before do
      board.setup
      board.put(black_rook, 'f4')
    end

    it 'returns an array of squares that enemy pieces are on in range of the piece' do
      expect(navigate_enemies.enemy_coordinates).to contain_exactly('f1', 'f2')
    end
  end

  describe '#legal_for' do
    subject(:navigator) { described_class.new(board, piece) }

    let(:board) { instance_double(Board) }
    let(:piece) { instance_double(Piece) }

    before do
      allow(board).to receive(:coordinates).twice
      allow(piece).to receive(:legal).twice
    end

    it 'sends piece a legal message' do
      navigator.legal_for(piece)
      expect(piece).to have_received(:legal)
    end

    it 'sends board a coordinates message' do
      navigator.legal_for(piece)
      expect(board).to have_received(:coordinates)
    end
  end

  describe '#passable?' do
    context 'when square is in bounds and not occupied' do
      subject(:passable_navigator) { described_class.new(board, king) }

      let(:board) { instance_double(Board) }
      let(:king) { instance_double(King) }
      let(:square) { instance_double(Square) }

      before do
        move = 'a4'
        allow(board).to receive(:in_bounds?).with(move).and_return(true)
        allow(square).to receive(:occupied?).and_return(false)
      end

      it 'returns true' do
        move = 'a4'
        expect(passable_navigator.passable?(move, square)).to be true
      end
    end

    context 'when square is not in bounds or occupied' do
      subject(:impassable_navigator) { described_class.new(board, queen) }

      let(:board) { instance_double(Board) }
      let(:queen) { instance_double(Queen) }
      let(:square) { instance_double(Square) }

      before do
        move = 'b7'
        allow(board).to receive(:in_bounds?).with(move).and_return(true)
        allow(square).to receive(:occupied?).and_return(true)
      end

      it 'returns false' do
        move = 'b7'
        expect(impassable_navigator.passable?(move, square)).to be false
      end
    end
  end
end

describe RookNavigator do
  describe '#possible_moves' do
    context 'when checking starting moves' do
      subject(:navigate_possibilities) { described_class.new(board, white_rook) }

      let(:board) { Board.new }
      let(:white_rook) { board.find_piece('h1') }
      let(:coordinate_system) { Coordinate }

      before do
        board.setup
      end

      it "returns a collection of Rook's possible coordinates" do
        expect(navigate_possibilities.possible_moves).to be_empty
      end
    end

    context 'when game is underway' do
      subject(:navigate_rook) { described_class.new(board, black_rook) }

      let(:board) { Board.new }
      let(:black_rook) { Rook.new('e4', colour: 'black') }
      let(:white_bishop) { Bishop.new('e2', colour: 'white') }
      let(:black_knight) { Knight.new('f4', colour: 'black') }
      let(:coordinate_system) { Coordinate }

      before do
        board.put(black_rook, 'e4')
        board.put(white_bishop, 'e2')
        board.put(white_bishop, 'e8')
        board.put(white_bishop, 'g4')
        board.put(black_knight, 'f4')
        board.put(black_knight, 'c4')
        board.put(black_knight, 'a4')
      end

      it 'correctly interprets collision' do
        correct_coordinates = %w[e2 e3 e5 e6 e7 e8 d4]
        result = correct_coordinates.map { |coordinate| coordinate_system.parse(coordinate) }
        expect(navigate_rook.possible_moves).to match_array(result)
      end
    end
  end
end

describe BishopNavigator do
  describe '#possible_moves' do
    context 'when checking starting moves' do
      subject(:navigate_possibilities) { described_class.new(board, black_bishop) }

      let(:board) { Board.new }
      let(:coordinate_system) { Coordinate }
      let(:black_bishop) { board.find_piece('c8') }

      before do
        board.setup
      end

      it "returns a collection of Bishop's possible coordinates" do
        expect(navigate_possibilities.possible_moves).to be_empty
      end
    end

    context 'when game is underway' do
      subject(:navigate_bishop) { described_class.new(board, white_bishop) }

      let(:board) { Board.new }
      let(:white_bishop) { board.find_piece('e4') }
      let(:coordinate_system) { Coordinate }

      before do
        board.setup('8/1n6/6R1/3n4/4B3/5R2/8/1r4n1')
      end

      it 'correctly interprets collision' do
        correct_coordinates = %w[b1 c2 d3 d5 f5]
        result = correct_coordinates.map { |coordinate| coordinate_system.parse(coordinate) }
        expect(navigate_bishop.possible_moves).to match_array(result)
      end
    end
  end
end

describe KnightNavigator do
  describe '#possible_moves' do
    context 'when checking starting moves' do
      subject(:navigate_possibilities) { described_class.new(board, white_knight) }

      let(:board) { Board.new }
      let(:coordinate_system) { Coordinate }
      let(:white_knight) { board.find_piece('g1') }

      before do
        board.setup
      end

      it "returns a collection of Knight's possible coordinates" do
        expect(navigate_possibilities.possible_moves).to contain_exactly('f3', 'h3')
      end
    end
  end
end

describe QueenNavigator do
  describe '#possible_moves' do
    context 'when checking starting moves' do
      subject(:navigate_possibilities) { described_class.new(board, black_queen) }

      let(:board) { Board.new }
      let(:coordinate_system) { Coordinate }
      let(:black_queen) { board.find_piece('d8') }

      before do
        board.setup
      end

      it "returns a collection of Queen's possible coordinates" do
        expect(navigate_possibilities.possible_moves).to be_empty
      end
    end

    context 'when game is underway' do
      subject(:navigate_queen) { described_class.new(board, black_queen) }

      let(:board) { Board.new }
      let(:black_queen) { board.find_piece('c6') }
      let(:coordinate_system) { Coordinate }

      before do
        board.setup('4r3/2N5/r1q1r1N1/6N1/N7/5N2/2r3N1/2N5')
      end

      it 'correctly interprets collision' do
        correct_coordinates = %w[a8 b7 a4 b5 b6 c7 c5 c4 c3 d7 d6 d5 e4 f3]
        result = correct_coordinates.map { |coordinate| coordinate_system.parse(coordinate) }
        expect(navigate_queen.possible_moves).to match_array(result)
      end
    end
  end
end

describe KingNavigator do
  describe '#possible_moves' do
    context 'when checking starting moves' do
      subject(:navigate_possibilities) { described_class.new(board, white_king) }

      let(:board) { Board.new }
      let(:coordinate_system) { Coordinate }
      let(:white_king) { board.find_piece('e1') }

      before do
        board.setup
      end

      it "returns a collection of King's possible coordinates" do
        expect(navigate_possibilities.possible_moves).to be_empty
      end
    end

    xcontext 'when castling is possible' do
      it 'includes it as a possible move' do
      end
    end
  end

  describe '#can_castle_kingside?' do
    context 'when kingside castling is possible' do
      subject(:possible_kingside) { described_class.new(board, white_king) }

      let(:board) { Board.new }
      let(:coordinate) { Coordinate }
      let(:white_king) { instance_double(King, position: coordinate.parse('e1'), colour: 'white') }
      let(:white_rook) { instance_double(Rook, position: coordinate.parse('h1'),  colour: 'white', instance_of?: Rook) }

      before do
        board.put(white_king, 'e1')
        board.put(white_rook, 'h1')
        allow(white_rook).to receive(:can_castle?).and_return(true)
      end

      it 'returns true' do
        expect(possible_kingside.can_castle_kingside?).to be true
      end
    end

    context 'when kingside castling is not possible' do
      subject(:impossible_kingside) { described_class.new(board, black_king) }

      let(:board) { Board.new }
      let(:coordinate) { Coordinate }
      let(:black_king) { instance_double(King, position: coordinate.parse('e8'), colour: 'black') }
      let(:black_rook) { instance_double(Rook, position: coordinate.parse('h8'), colour: 'black', instance_of?: Rook) }

      before do
        board.put(black_king, 'e8')
        board.put(black_rook, 'h8')
        allow(black_rook).to receive(:can_castle?).and_return(false)
      end

      it 'returns false' do
        expect(impossible_kingside.can_castle_kingside?).to be false
      end
    end
  end
end

describe PawnNavigator do
  describe '#possible_moves' do
    context 'when checking starting moves' do
      let(:board) { Board.new }
      let(:coordinate_system) { Coordinate }

      before do
        board.setup
      end

      context 'when Pawn is white' do
        subject(:navigate_possibilities) { described_class.new(board, white_pawn) }

        let(:white_pawn) { board.find_piece('b2') }

        it "returns a collection of white Pawn's possible coordinates" do
          correct_coordinates = %w[b3 b4]
          result = correct_coordinates.map { |coordinate| coordinate_system.parse(coordinate) }
          expect(navigate_possibilities.possible_moves).to match_array(result)
        end
      end

      context 'when Pawn is black' do
        subject(:navigate_possibilities) { described_class.new(board, black_pawn) }

        let(:black_pawn) { board.find_piece('d7') }

        it "returns a collection of black Pawn's possible coordinates" do
          correct_coordinates = %w[d5 d6]
          result = correct_coordinates.map { |coordinate| coordinate_system.parse(coordinate) }
          expect(navigate_possibilities.possible_moves).to match_array(result)
        end
      end

      context 'when Pawn was already moved' do
        subject(:pawn_no_double) { described_class.new(board, white_pawn) }

        let!(:white_pawn) { board.find_piece('d2') }

        it 'does not allow double move' do
          result = [coordinate_system.parse('d4')]
          board.move_piece('d2', 'd3')
          expect(pawn_no_double.possible_moves).to match_array(result)
        end
      end
    end

    context 'when Pawn can take' do
      subject(:pawn_taking) { described_class.new(board, black_pawn) }

      let(:board) { Board.new }
      let(:black_pawn) { board.find_piece('d5') }
      # See 'when Pawn was already moved' above? No idea why that works with let! but this doesn't. So I had to grab the piece after it's been moved.
      let(:coordinate) { Coordinate }

      before do
        board.setup
        board.move_piece('d7', 'd5')
        board.move_piece('e2', 'e4')
        board.move_piece('c2', 'c4')
      end

      it 'includes takes as moves' do
        moves = %w[c4 d4 e4].map { |move| coordinate.parse(move) }
        expect(pawn_taking.possible_moves).to match_array(moves)
      end
    end

    xcontext 'when en passant is possible' do
      it 'includes it as a move' do
      end
    end
  end

  describe '#promoteable?' do
    context 'when Pawn is white' do
      subject(:promo_white_pawn) { described_class.new(board, white_pawn) }

      let(:board) { instance_double(Board) }
      let(:white_pawn) { instance_double(Pawn, colour: 'white') }

      context 'when pawn is on the 8th row' do
        before do
          allow(white_pawn).to receive(:position).and_return('a8')
        end

        it 'returns true' do
          expect(promo_white_pawn.promoteable?).to be true
        end
      end

      context 'when pawn is not on the 8th row' do
        before do
          allow(white_pawn).to receive(:position).and_return('d3')
        end

        it 'returns false' do
          expect(promo_white_pawn.promoteable?).to be false
        end
      end
    end

    context 'when Pawn is black' do
      subject(:promo_black_pawn) { described_class.new(board, black_pawn) }

      let(:board) { instance_double(Board) }
      let(:black_pawn) { instance_double(Pawn, colour: 'black') }

      context 'when pawn is on the 1st row' do
        before do
          allow(black_pawn).to receive(:position).and_return('h1')
        end

        it 'returns true when on 1st row' do
          expect(promo_black_pawn.promoteable?).to be true
        end
      end

      context 'when pawn is not on the 1st row' do
        before do
          allow(black_pawn).to receive(:position).and_return('g8')
        end

        it 'returns false otherwise' do
          expect(promo_black_pawn.promoteable?).to be false
        end
      end
    end
  end
end
