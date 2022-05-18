# frozen_string_literal: true

require_relative '../lib/boardnavigator'
require_relative '../lib/board'

# rubocop: disable Metrics/BlockLength, Layout/LineLength,
describe BoardNavigator do
  describe '#in_bounds_coordinates' do
    coordinates = %w[a1 a2 a3 a4 a5 a6 a7 a8
                     b1 b2 b3 b4 b5 b6 b7 b8
                     c1 c2 c3 c4 c5 c6 c7 c8
                     d1 d2 d3 d4 d5 d6 d7 d8
                     e1 e2 e3 e4 e5 e6 e7 e8
                     f1 f2 f3 f4 f5 f6 f7 f8
                     g1 g2 g3 g4 g5 g6 g7 g8
                     h1 h2 h3 h4 h5 h6 h7 h8]
    context "when checking Kings's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { instance_double(Board) }
      let(:king) { instance_double(King, position: 'd4') }
      before do
        allow(board).to receive(:coordinates).and_return(coordinates)
        allow(king).to receive(:legal?).and_return(false)
        allow(king).to receive(:legal?).with('d3').and_return(true)
        allow(king).to receive(:legal?).with('d5').and_return(true)
        allow(king).to receive(:legal?).with('c3').and_return(true)
        allow(king).to receive(:legal?).with('c4').and_return(true)
        allow(king).to receive(:legal?).with('c5').and_return(true)
        allow(king).to receive(:legal?).with('e3').and_return(true)
        allow(king).to receive(:legal?).with('e4').and_return(true)
        allow(king).to receive(:legal?).with('e5').and_return(true)
      end
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_coordinates(king)).to contain_exactly('d3', 'd5', 'c3', 'c4', 'c5', 'e3', 'e4', 'e5')
      end
    end

    context "when checking Knight's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:knight) { Knight.new('b8') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_coordinates(knight)).to contain_exactly('a6', 'c6', 'd7')
      end
    end

    context "when checking Pawns's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      context 'when Pawn is white' do
        let(:white_pawn) { Pawn.new('b3', colour: 'white') }
        it 'provides an array of possible moves' do
          white_pawn.move('b4')
          expect(navigate_bounds.in_bounds_coordinates(white_pawn)).to contain_exactly('a5', 'b5', 'c5')
        end
      end
      context 'when Pawn is black' do
        let(:black_pawn) { Pawn.new('b5', colour: 'black') }
        it 'provides an array of possible moves' do
          black_pawn.move('b4')
          expect(navigate_bounds.in_bounds_coordinates(black_pawn)).to contain_exactly('a3', 'b3', 'c3')
        end
      end
    end

    context "when checking Queens's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:queen) { Queen.new('c3') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_coordinates(queen)).to contain_exactly('c1', 'c2', 'c4', 'c5', 'c6', 'c7', 'c8',
                                                                                'a3', 'b3', 'd3', 'e3', 'f3', 'g3', 'h3',
                                                                                'a1', 'b2', 'd4', 'e5', 'f6', 'g7', 'h8',
                                                                                'b4', 'a5', 'd2', 'e1')
      end
    end

    context "when checking Rook's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:rook) { Rook.new('b3') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_coordinates(rook)).to contain_exactly('b1', 'b2', 'b4', 'b5', 'b6', 'b7', 'b8',
                                                                               'a3', 'c3', 'd3', 'e3', 'f3', 'g3', 'h3')
      end
    end

    context "when checking Bishop's in bounds moves" do
      subject(:navigate_bounds) { described_class.new(board) }
      let(:board) { Board.new }
      let(:bishop) { Bishop.new('e4') }
      it 'provides an array of possible moves' do
        expect(navigate_bounds.in_bounds_coordinates(bishop)).to contain_exactly('d3', 'c2', 'b1',
                                                                                 'd5', 'c6', 'b7', 'a8',
                                                                                 'f3', 'g2', 'h1',
                                                                                 'f5', 'g6', 'h7')
      end
    end
  end

  describe '#occupied_coordinates' do
    subject(:navigate_collison) { described_class.new(board) }
    let(:board) { Board.new }
    let(:queen) { Queen.new('d4') }
    before do
      board.setup
      board.put(queen, 'd4')
    end
    it 'returns an array of occupied squares' do
      expect(navigate_collison.occupied_coordinates(queen)).to contain_exactly('d1', 'd2', 'd7', 'd8',
                                                                               'a1', 'b2', 'g7', 'h8',
                                                                               'g1', 'f2', 'a7')
    end
  end

  describe '#allied_coordinates' do
    subject(:navigate_allies) { described_class.new(board) }
    let(:board) { Board.new }
    before do
      board.setup
    end
    it 'returns an array of squares that allied pieces are on in range of the piece' do
      white_rook = board.find_piece('a1')
      expect(navigate_allies.allied_coordinates(white_rook)).to contain_exactly('a2',
                                                                                'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1')
    end
  end

  describe '#enemy_coordinates' do
    subject(:navigate_enemies) { described_class.new(board) }
    let(:board) { Board.new }
    let(:black_rook) { Rook.new('f4', colour: 'black') }
    before do
      board.setup
      board.put(black_rook, 'f4')
    end
    it 'returns an array of squares that enemy pieces are on in range of the piece' do
      expect(navigate_enemies.enemy_coordinates(black_rook)).to contain_exactly('f1', 'f2')
    end
  end

  describe '#possible_moves' do
    context 'when checking starting moves' do
      subject(:navigate_possibilities) { described_class.new(board) }
      let(:board) { Board.new }
      before do
        board.setup
      end
      context "when checking Rook's possible moves" do
        it 'returns a collection of possible coordinates' do
          white_rook = board.find_piece('h1')
          expect(navigate_possibilities.possible_moves(white_rook)).to be_empty
        end
      end

      context "when checking Bishop's possible moves" do
        it 'returns a collection of possible coordinates' do
          black_bishop = board.find_piece('c8')
          expect(navigate_possibilities.possible_moves(black_bishop)).to be_empty
        end
      end

      context "when checking Knight's possible moves" do
        it 'returns a collection of possible coordinates' do
          white_knight = board.find_piece('g1')
          expect(navigate_possibilities.possible_moves(white_knight)).to contain_exactly('f3', 'h3')
        end
      end

      context "when checking Queen's possible moves" do
        it 'returns a collection of possible coordinates' do
          black_queen = board.find_piece('d8')
          expect(navigate_possibilities.possible_moves(black_queen)).to be_empty
        end
      end

      context "when checking King's possible moves" do
        it 'returns a collection of possible coordinates' do
          white_king = board.find_piece('e1')
          expect(navigate_possibilities.possible_moves(white_king)).to be_empty
        end
      end

      context "when checking Pawn's possible moves" do
        context 'when Pawn is white' do
          it 'returns a collection of possible coordinates' do
            white_pawn = board.find_piece('b2')
            expect(navigate_possibilities.possible_moves(white_pawn)).to contain_exactly('b3', 'b4')
          end
        end
        context 'when Pawn is black' do
          it 'returns a collection of possible coordinates' do
            black_pawn = board.find_piece('d7')
            expect(navigate_possibilities.possible_moves(black_pawn)).to contain_exactly('d6', 'd5')
          end
        end
      end
    end

    context 'when game is underway' do
      context 'when Rook checks its moves' do
        subject(:navigate_rook) { described_class.new(board) }
        let(:board) { Board.new }
        let(:black_rook) { Rook.new('e4', colour: 'black') }
        let(:white_bishop) { Bishop.new(nil, colour: 'white') }
        let(:black_knight) { Knight.new(nil, colour: 'black') }
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
          expect(navigate_rook.possible_moves(black_rook)).to contain_exactly('e2', 'e3',
                                                                              'e5', 'e6', 'e7', 'e8',
                                                                              'd4')
        end
      end
      context 'when Bishop checks its moves' do
        subject(:navigate_bishop) { described_class.new(board) }
        let(:board) { Board.new }
        let(:white_bishop) { Bishop.new('e4', colour: 'white') }
        let(:white_rook) { Rook.new(nil, colour: 'white') }
        let(:black_rook) { Rook.new(nil, colour: 'black') }
        let(:black_knight) { Knight.new(nil, colour: 'black') }
        before do
          board.put(white_bishop, 'e4')
          board.put(white_rook, 'f3')
          board.put(white_rook, 'g6')
          board.put(black_rook, 'b1')
          board.put(black_knight, 'd5')
          board.put(black_knight, 'b7')
          board.put(black_knight, 'g1')
        end
        it 'correctly interprets collision' do
          expect(navigate_bishop.possible_moves(white_bishop)).to contain_exactly('b1', 'c2', 'd3',
                                                                                  'd5',
                                                                                  'f5')
        end
      end
      context 'when Queen checks its moves' do
        subject(:navigate_queen) { described_class.new(board) }
        let(:board) { Board.new }
        let(:black_queen) { Queen.new('c6', colour: 'black') }
        let(:black_rook) { Rook.new(nil, colour: 'black') }
        let(:white_knight) { Knight.new(nil, colour: 'white') }
        before do
          board.put(black_queen, 'c6')
          board.put(black_rook, 'a6')
          board.put(black_rook, 'e6')
          board.put(black_rook, 'e8')
          board.put(black_rook, 'c2')
          board.put(white_knight, 'c7')
          board.put(white_knight, 'a4')
          board.put(white_knight, 'c1')
          board.put(white_knight, 'f3')
          board.put(white_knight, 'g2')
          board.put(white_knight, 'g5')
          board.put(white_knight, 'g6')
        end
        it 'correctly interprets collision' do
          expect(navigate_queen.possible_moves(black_queen)).to contain_exactly('a8', 'b7',
                                                                                'a4', 'b5',
                                                                                'b6',
                                                                                'c7',
                                                                                'c5', 'c4', 'c3',
                                                                                'd7',
                                                                                'd6',
                                                                                'd5',
                                                                                'e4',
                                                                                'f3')
        end
      end
    end

    context 'when castling is possible' do
      subject(:navigate_castling) { described_class.new(board) }
      let(:board) { Board.new }
      before do
        board.send(:setup_kings)
        board.send(:setup_rooks)
        board.send(:setup_pawns)
      end
      xit 'includes it as a possible move' do
        white_king = board.find_piece('e1')
        expect(navigate_castling.possible_moves(white_king)).to contain_exactly('d1', 'f1',
                                                                                'g1', 'c1')
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

    context 'when Pawn can take' do
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
        allow(navigate_pawn_taking).to receive(:mark_occupied).with(white_pawn, %w[d5 c5 e5]).and_return(%w[d5E c5E e5A])
        allow(navigate_pawn_taking).to receive(:mark_occupied).with(black_pawn, %w[d4 c4 e4]).and_return(%w[d4E c4E e4A])
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
# rubocop: enable Metrics/BlockLength, Layout/LineLength,
