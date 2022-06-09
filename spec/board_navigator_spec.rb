# frozen_string_literal: true

require_relative '../lib/board_navigator'
require_relative '../lib/board'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

# rubocop: disable Layout/LineLength,
describe BoardNavigator do
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

  describe '#legal_for' do
    subject(:navigator) { described_class.new(board) }

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

  describe '#possible_moves' do
    context 'when checking starting moves' do
      subject(:navigate_possibilities) { described_class.new(board) }

      let(:board) { Board.new }
      let(:coordinate_system) { Coordinate }

      before do
        board.setup
      end

      it "returns a collection of Rook's possible coordinates" do
        white_rook = board.find_piece('h1')
        expect(navigate_possibilities.possible_moves(white_rook)).to be_empty
      end

      it "returns a collection of Bishop's possible coordinates" do
        black_bishop = board.find_piece('c8')
        expect(navigate_possibilities.possible_moves(black_bishop)).to be_empty
      end

      it "returns a collection of Knight's possible coordinates" do
        white_knight = board.find_piece('g1')
        expect(navigate_possibilities.possible_moves(white_knight)).to contain_exactly('f3', 'h3')
      end

      it "returns a collection of Queen's possible coordinates" do
        black_queen = board.find_piece('d8')
        expect(navigate_possibilities.possible_moves(black_queen)).to be_empty
      end

      it "returns a collection of King's possible coordinates" do
        white_king = board.find_piece('e1')
        expect(navigate_possibilities.possible_moves(white_king)).to be_empty
      end

      it "returns a collection of white Pawn's possible coordinates" do
        white_pawn = board.find_piece('b2')
        correct_coordinates = %w[b3 b4]
        result = correct_coordinates.map { |coordinate| coordinate_system.parse(coordinate) }
        expect(navigate_possibilities.possible_moves(white_pawn)).to match_array(result)
      end

      it "returns a collection of black Pawn's possible coordinates" do
        black_pawn = board.find_piece('d7')
        correct_coordinates = %w[d5 d6]
        result = correct_coordinates.map { |coordinate| coordinate_system.parse(coordinate) }
        expect(navigate_possibilities.possible_moves(black_pawn)).to match_array(result)
      end
    end

    context 'when game is underway' do
      context 'when Rook checks its moves' do
        subject(:navigate_rook) { described_class.new(board) }

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
          expect(navigate_rook.possible_moves(black_rook)).to match_array(result)
        end
      end

      context 'when Bishop checks its moves' do
        subject(:navigate_bishop) { described_class.new(board) }

        let(:board) { Board.new }
        let(:white_bishop) { Bishop.new('e4', colour: 'white') }
        let(:white_rook) { Rook.new('f3', colour: 'white') }
        let(:black_rook) { Rook.new('b1', colour: 'black') }
        let(:black_knight) { Knight.new('d5', colour: 'black') }
        let(:coordinate_system) { Coordinate }

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
          correct_coordinates = %w[b1 c2 d3 d5 f5]
          result = correct_coordinates.map { |coordinate| coordinate_system.parse(coordinate) }
          expect(navigate_bishop.possible_moves(white_bishop)).to match_array(result)
        end
      end

      context 'when Queen checks its moves' do
        subject(:navigate_queen) { described_class.new(board) }

        let(:board) { Board.new }
        let(:black_queen) { Queen.new('c6', colour: 'black') }
        let(:black_rook) { Rook.new('a6', colour: 'black') }
        let(:white_knight) { Knight.new('c7', colour: 'white') }
        let(:coordinate_system) { Coordinate }

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
          correct_coordinates = %w[a8 b7 a4 b5 b6 c7 c5 c4 c3 d7 d6 d5 e4 f3]
          result = correct_coordinates.map { |coordinate| coordinate_system.parse(coordinate) }
          expect(navigate_queen.possible_moves(black_queen)).to match_array(result)
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
# rubocop: enable Layout/LineLength,
