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

  describe '#go_left' do
    subject(:leftbound_rook) { described_class.new(board, white_rook) }

    let(:board) { instance_double(Board) }
    let(:white_rook) { instance_double(Rook, position: coordinate.parse('d1'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:black_piece) { instance_double(Piece, position: coordinate.parse('b1')) }
    let(:square) { instance_double(Square, piece: black_piece) }

    before do
      allow(board).to receive(:find).with(white_rook.position.left.to_s).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_rook.position.left.left.to_s).and_return(true)
      allow(board).to receive(:find).with(white_rook.position.left.left.to_s).and_return(square)
      allow(white_rook).to receive(:enemy?).with(black_piece).and_return(true).once
      allow(board).to receive(:find).with(white_rook.position.left.left.left.to_s).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_rook.position.left.left.left.to_s).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[b1 c1].map { |move| coordinate.parse(move) }
      expect(leftbound_rook.go_left).to match_array(moves)
    end
  end

  describe '#go_right' do
    subject(:rightbound_rook) { described_class.new(board, white_rook) }

    let(:board) { instance_double(Board) }
    let(:white_rook) { instance_double(Rook, position: coordinate.parse('e1'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:black_piece) { instance_double(Piece, position: coordinate.parse('g1')) }
    let(:square) { instance_double(Square, piece: black_piece) }

    before do
      allow(board).to receive(:find).with(white_rook.position.right.to_s).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_rook.position.right.right.to_s).and_return(true)
      allow(board).to receive(:find).with(white_rook.position.right.right.to_s).and_return(square)
      allow(white_rook).to receive(:enemy?).with(black_piece).and_return(true).once
      allow(board).to receive(:find).with(white_rook.position.right.right.right.to_s).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_rook.position.right.right.right.to_s).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[f1 g1].map { |move| coordinate.parse(move) }
      expect(rightbound_rook.go_right).to match_array(moves)
    end
  end

  describe '#go_up' do
    subject(:upbound_rook) { described_class.new(board, white_rook) }

    let(:board) { instance_double(Board) }
    let(:white_rook) { instance_double(Rook, position: coordinate.parse('f5'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:white_piece) { instance_double(Piece, position: coordinate.parse('f6')) }
    let(:square) { instance_double(Square, piece: white_piece) }

    before do
      allow(board).to receive(:find).with(white_rook.position.up.to_s).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_rook.position.up.up.to_s).and_return(true)
      allow(board).to receive(:find).with(white_rook.position.up.up.to_s).and_return(square)
      allow(white_rook).to receive(:enemy?).with(white_piece).and_return(false)
      allow(board).to receive(:find).with(white_rook.position.up.up.up.to_s).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_rook.position.up.up.up.to_s).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[f6].map { |move| coordinate.parse(move) }
      expect(upbound_rook.go_up).to match_array(moves)
    end
  end

  describe '#go_down' do
    subject(:downbound_rook) { described_class.new(board, white_rook) }

    let(:board) { instance_double(Board) }
    let(:white_rook) { instance_double(Rook, position: coordinate.parse('e4'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:white_piece) { instance_double(Piece, position: coordinate.parse('e2')) }
    let(:square) { instance_double(Square, piece: white_piece) }

    before do
      allow(board).to receive(:find).with(white_rook.position.down.to_s).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_rook.position.down.down.to_s).and_return(true)
      allow(board).to receive(:find).with(white_rook.position.down.down.to_s).and_return(square)
      allow(white_rook).to receive(:enemy?).with(white_piece).and_return(false)
      allow(board).to receive(:find).with(white_rook.position.down.down.down.to_s).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_rook.position.down.down.down.to_s).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[e3].map { |move| coordinate.parse(move) }
      expect(downbound_rook.go_down).to match_array(moves)
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

  describe '#go_up_left' do
    subject(:up_left_bishop) { described_class.new(board, white_bishop) }

    let(:board) { instance_double(Board) }
    let(:white_bishop) { instance_double(Rook, position: coordinate.parse('d5'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:black_piece) { instance_double(Piece, position: coordinate.parse('b7')) }
    let(:square) { instance_double(Square, piece: black_piece) }

    before do
      allow(board).to receive(:find).with(white_bishop.position.up.left.to_s).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.up.left.up.left.to_s).and_return(true)
      allow(board).to receive(:find).with(white_bishop.position.up.left.up.left.to_s).and_return(square)
      allow(white_bishop).to receive(:enemy?).with(black_piece).and_return(true).once
      allow(board).to receive(:find).with(white_bishop.position.up.left.up.left.up.left.to_s).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.up.left.up.left.up.left.to_s).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[c6 b7].map { |move| coordinate.parse(move) }
      expect(up_left_bishop.go_up_left).to match_array(moves)
    end
  end

  describe '#go_up_right' do
    subject(:up_right_bishop) { described_class.new(board, white_bishop) }

    let(:board) { instance_double(Board) }
    let(:white_bishop) { instance_double(Rook, position: coordinate.parse('e5'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:black_piece) { instance_double(Piece, position: coordinate.parse('g7')) }
    let(:square) { instance_double(Square, piece: black_piece) }

    before do
      allow(board).to receive(:find).with(white_bishop.position.up.right.to_s).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.up.right.up.right.to_s).and_return(true)
      allow(board).to receive(:find).with(white_bishop.position.up.right.up.right.to_s).and_return(square)
      allow(white_bishop).to receive(:enemy?).with(black_piece).and_return(true).once
      allow(board).to receive(:find).with(white_bishop.position.up.right.up.right.up.right.to_s).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.up.right.up.right.up.right.to_s).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[f6 g7].map { |move| coordinate.parse(move) }
      expect(up_right_bishop.go_up_right).to match_array(moves)
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
        board.setup('4r3/2N5/r1q1r1N/6N1/N7/5N2/2r3N1/2N5')
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

    xcontext 'when King would put itself in check' do
      subject(:navigate_check) { described_class.new(board) }

      let(:board) { Board.new }
      let(:black_rook) { instance_double(Rook, position: 'd8', colour: 'black') }
      let(:white_rook) { instance_double(Rook, position: 'f3', colour: 'white') }
      let(:white_king) { instance_double(King, position: 'e3', colour: 'white') }

      before do
        board.put(white_rook, 'f3')
        board.put(black_rook, 'd8')
        board.put(white_king, 'e3')
        allow(navigate_check).to receive(:in_bounds_coordinates).with(white_king)
        allow(navigate_check).to receive(:allied_coordinates).with(white_king)
      end

      it "doesn't include those moves" do
        expect(navigate_check.possible_moves(white_king)).to contain_exactly('e2', 'e4',
                                                                             'f2', 'f4')
      end
    end

    xcontext 'when castling is possible' do
      subject(:navigate_castling) { described_class.new(board) }

      let(:board) { Board.new }

      before do
        board.send(:setup_kings)
        board.send(:setup_rooks)
        board.send(:setup_pawns)
      end

      it 'includes it as a possible move' do
        white_king = board.find_piece('e1')
        expect(navigate_castling.possible_moves(white_king)).to contain_exactly('d1', 'f1',
                                                                                'g1', 'c1')
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
    end

    xcontext 'when Pawn can take' do
      subject(:navigate_pawn_taking) { described_class.new(board) }

      let(:board) { Board.new }
      let(:white_piece) { instance_double(Piece, colour: 'white') }
      let(:black_piece) { instance_double(Piece, colour: 'black') }
      let(:white_pawn) { instance_double(Pawn, position: 'd4', colour: 'white') }
      let(:black_pawn) { instance_double(Pawn, position: 'd5', colour: 'black') }

      before do
        board.put(black_piece, 'c5')
        board.put(black_piece, 'e4')
        board.put(white_piece, 'c4')
        board.put(white_piece, 'e5')
        board.put(white_pawn, 'd4')
        board.put(black_pawn, 'd5')
        allow(white_pawn).to receive(:class).and_return('Pawn')
        allow(black_pawn).to receive(:class).and_return('Pawn')
        allow(white_pawn).to receive(:split_moves).with(%w[d5E c5E e5A]).and_return([['d5E'], ['c5E'], ['e5A']])
        allow(black_pawn).to receive(:split_moves).with(%w[d4E c4E e4A]).and_return([['d4E'], ['c4E'], ['e4A']])
        allow(navigate_pawn_taking).to receive(:mark_occupied).with(white_pawn,
                                                                    %w[d5 c5 e5]).and_return(%w[d5E c5E e5A])
        allow(navigate_pawn_taking).to receive(:mark_occupied).with(black_pawn,
                                                                    %w[d4 c4 e4]).and_return(%w[d4E c4E e4A])
        allow(navigate_pawn_taking).to receive(:in_bounds_coordinates).with(white_pawn).and_return(%w[d5 c5 e5])
        allow(navigate_pawn_taking).to receive(:in_bounds_coordinates).with(black_pawn).and_return(%w[d4 c4 e4])
      end

      context 'when it is white' do
        it 'includes the takes as possible move' do
          expect(navigate_pawn_taking.possible_moves(white_pawn)).to contain_exactly('c5')
        end
      end

      context 'when it is black' do
        it 'includes the takes as possible move' do
          expect(navigate_pawn_taking.possible_moves(black_pawn)).to contain_exactly('c4')
        end
      end
    end

    xcontext 'when en passant is possible' do
      subject(:navigate_en_passant) { described_class.new(board) }

      let(:board) { Board.new }
      let(:white_pawn) { instance_double(Pawn, position: 'g5', colour: 'white') }
      let(:black_pawn) { instance_double(Pawn, position: 'f7', colour: 'black') }

      before do
        board.put(white_pawn, 'g5')
        board.put(black_pawn, 'f7')
        allow(navigate_en_passant).to receive(:in_bounds_coordinates).with(white_pawn).and_return(%w[f6 g6 h6])
        allow(navigate_en_passant).to receive(:enemy_coordinates).with(white_pawn).and_return(['f6'])
        allow(navigate_en_passant).to receive(:allied_coordinates).with(white_pawn).and_return([])
      end

      it 'includes it as a possibility' do
        board.move_piece('f7', 'f5')
        expect(navigate_en_passant.possible_moves(white_pawn)).to contain_exactly('f6', 'g6')
      end
    end
  end
end
