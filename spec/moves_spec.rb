# frozen_string_literal: true

require_relative '../lib/moves'
require_relative '../lib/piece_navigator'
require_relative '../lib/board'
require_relative '../lib/board_navigator'

# rubocop: disable RSpec/MultipleMemoizedHelpers
describe Moves::HorizontalMoves do
  describe '#go_left' do
    subject(:leftbound_rook) { PieceNavigator.new(board_navigator, white_rook) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_rook) { instance_double(Rook, position: coordinate.parse('d1'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:black_piece) { instance_double(Piece, position: coordinate.parse('b1')) }
    let(:square) { instance_double(Square, piece: black_piece) }

    before do
      leftbound_rook.extend(described_class)
      allow(board).to receive(:find).with(white_rook.position.left).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_rook.position.left.left).and_return(true)
      allow(board).to receive(:find).with(white_rook.position.left.left).and_return(square)
      allow(white_rook).to receive(:enemy?).with(black_piece).and_return(true).once
      allow(board).to receive(:find).with(white_rook.position.left.left.left).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_rook.position.left.left.left).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[b1 c1].map { |move| coordinate.parse(move) }
      expect(leftbound_rook.go_left).to match_array(moves)
    end
  end

  describe '#go_right' do
    subject(:rightbound_rook) { PieceNavigator.new(board_navigator, white_rook) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_rook) { instance_double(Rook, position: coordinate.parse('e1'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:black_piece) { instance_double(Piece, position: coordinate.parse('g1')) }
    let(:square) { instance_double(Square, piece: black_piece) }

    before do
      rightbound_rook.extend(described_class)
      allow(board).to receive(:find).with(white_rook.position.right).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_rook.position.right.right).and_return(true)
      allow(board).to receive(:find).with(white_rook.position.right.right).and_return(square)
      allow(white_rook).to receive(:enemy?).with(black_piece).and_return(true).once
      allow(board).to receive(:find).with(white_rook.position.right.right.right).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_rook.position.right.right.right).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[f1 g1].map { |move| coordinate.parse(move) }
      expect(rightbound_rook.go_right).to match_array(moves)
    end
  end

  describe '#go_up' do
    subject(:upbound_rook) { PieceNavigator.new(board_navigator, white_rook) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_rook) { instance_double(Rook, position: coordinate.parse('f5'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:white_piece) { instance_double(Piece, position: coordinate.parse('f6')) }
    let(:square) { instance_double(Square, piece: white_piece) }

    before do
      upbound_rook.extend(described_class)
      allow(board).to receive(:find).with(white_rook.position.up).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_rook.position.up.up).and_return(true)
      allow(board).to receive(:find).with(white_rook.position.up.up).and_return(square)
      allow(white_rook).to receive(:enemy?).with(white_piece).and_return(false)
      allow(board).to receive(:find).with(white_rook.position.up.up.up).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_rook.position.up.up.up).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[f6].map { |move| coordinate.parse(move) }
      expect(upbound_rook.go_up).to match_array(moves)
    end
  end

  describe '#go_down' do
    subject(:downbound_rook) { PieceNavigator.new(board_navigator, white_rook) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_rook) { instance_double(Rook, position: coordinate.parse('e4'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:white_piece) { instance_double(Piece, position: coordinate.parse('e2')) }
    let(:square) { instance_double(Square, piece: white_piece) }

    before do
      downbound_rook.extend(described_class)
      allow(board).to receive(:find).with(white_rook.position.down).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_rook.position.down.down).and_return(true)
      allow(board).to receive(:find).with(white_rook.position.down.down).and_return(square)
      allow(white_rook).to receive(:enemy?).with(white_piece).and_return(false)
      allow(board).to receive(:find).with(white_rook.position.down.down.down).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_rook.position.down.down.down).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[e3].map { |move| coordinate.parse(move) }
      expect(downbound_rook.go_down).to match_array(moves)
    end
  end
end

describe Moves::DiagonalMoves do
  describe '#go_up_left' do
    subject(:up_left_bishop) { PieceNavigator.new(board_navigator, white_bishop) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_bishop) { instance_double(Bishop, position: coordinate.parse('d5'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:black_piece) { instance_double(Piece, position: coordinate.parse('b7')) }
    let(:square) { instance_double(Square, piece: black_piece) }

    before do
      up_left_bishop.extend(described_class)
      allow(board).to receive(:find).with(white_bishop.position.up.left).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.up.left.up.left).and_return(true)
      allow(board).to receive(:find).with(white_bishop.position.up.left.up.left).and_return(square)
      allow(white_bishop).to receive(:enemy?).with(black_piece).and_return(true).once
      allow(board).to receive(:find).with(white_bishop.position.up.left.up.left.up.left).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.up.left.up.left.up.left).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[c6 b7].map { |move| coordinate.parse(move) }
      expect(up_left_bishop.go_up_left).to match_array(moves)
    end
  end

  describe '#go_up_right' do
    subject(:up_right_bishop) { PieceNavigator.new(board_navigator, white_bishop) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_bishop) { instance_double(Bishop, position: coordinate.parse('e5'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:black_piece) { instance_double(Piece, position: coordinate.parse('g7')) }
    let(:square) { instance_double(Square, piece: black_piece) }

    before do
      up_right_bishop.extend(described_class)
      allow(board).to receive(:find).with(white_bishop.position.up.right).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.up.right.up.right).and_return(true)
      allow(board).to receive(:find).with(white_bishop.position.up.right.up.right).and_return(square)
      allow(white_bishop).to receive(:enemy?).with(black_piece).and_return(true).once
      allow(board).to receive(:find).with(white_bishop.position.up.right.up.right.up.right).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.up.right.up.right.up.right).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[f6 g7].map { |move| coordinate.parse(move) }
      expect(up_right_bishop.go_up_right).to match_array(moves)
    end
  end

  describe '#go_down_right' do
    subject(:down_right_bishop) { PieceNavigator.new(board_navigator, white_bishop) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_bishop) { instance_double(Bishop, position: coordinate.parse('e4'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:white_piece) { instance_double(Piece, position: coordinate.parse('g2')) }
    let(:square) { instance_double(Square, piece: white_piece) }

    before do
      down_right_bishop.extend(described_class)
      allow(board).to receive(:find).with(white_bishop.position.down.right).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.down.right.down.right).and_return(true)
      allow(board).to receive(:find).with(white_bishop.position.down.right.down.right).and_return(square)
      allow(white_bishop).to receive(:enemy?).with(white_piece).and_return(false)
      allow(board).to receive(:find).with(white_bishop.position.down.right.down.right.down.right).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.down.right.down.right.down.right).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[f3].map { |move| coordinate.parse(move) }
      expect(down_right_bishop.go_down_right).to match_array(moves)
    end
  end

  describe '#go_down_left' do
    subject(:down_left_bishop) { PieceNavigator.new(board_navigator, white_bishop) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_bishop) { instance_double(Bishop, position: coordinate.parse('d4'), colour: 'white', coordinate:) }
    let(:coordinate) { Coordinate }
    let(:white_piece) { instance_double(Piece, position: coordinate.parse('b2')) }
    let(:square) { instance_double(Square, piece: white_piece) }

    before do
      down_left_bishop.extend(described_class)
      allow(board).to receive(:find).with(white_bishop.position.down.left).and_return(square)
      allow(square).to receive(:occupied?).and_return(false, false, true, true)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.down.left.down.left).and_return(true)
      allow(board).to receive(:find).with(white_bishop.position.down.left.down.left).and_return(square)
      allow(white_bishop).to receive(:enemy?).with(white_piece).and_return(false)
      allow(board).to receive(:find).with(white_bishop.position.down.left.down.left.down.left).and_return(square)
      allow(board).to receive(:in_bounds?).with(white_bishop.position.down.left.down.left.down.left).and_return(true)
    end

    it 'returns proper moves' do
      moves = %w[c3].map { |move| coordinate.parse(move) }
      expect(down_left_bishop.go_down_left).to match_array(moves)
    end
  end
end

describe Moves::CollisionlessMoves do
  describe '#collisonless_moves' do
    subject(:regular_knight) { PieceNavigator.new(board_navigator, white_knight) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_knight) { instance_double(Knight, position: coordinate.parse('a8'), colour: 'white') }
    let(:coordinate) { Coordinate }
    let(:white_piece) { instance_double(Piece, position: coordinate.parse('b6')) }
    let(:nil_piece) { instance_double(NilPiece) }

    before do
      regular_knight.extend(described_class)
      allow(board).to receive(:coordinates).and_return(%w[b6 c7])
      allow(white_knight).to receive(:legal).with(%w[b6 c7]).and_return(%w[b6 c7])
      allow(board).to receive(:piece_for).with('b6').and_return(white_piece)
      allow(white_knight).to receive(:ally?).with(white_piece).and_return(true)
      allow(board).to receive(:piece_for).with('c7').and_return(nil_piece)
      allow(white_knight).to receive(:ally?).with(nil_piece).and_return(false)
    end

    it 'rejects spaces occupied by allies' do
      correct_moves = %w[c7]
      expect(regular_knight.collisionless_moves).to match_array(correct_moves)
    end
  end
end

describe Moves::PawnTakes do
  context 'when Pawn is white' do
    subject(:white_pawn_piece) { PieceNavigator.new(board_navigator, white_piece) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:white_piece) { instance_double(Piece, position: coordinate.parse('b4'), colour: 'white') }
    let(:coordinate) { Coordinate }
    let(:black_piece) { instance_double(Piece, colour: 'black') }
    let(:square) { instance_double(Square) }
    let(:nil_piece) { instance_double(NilPiece) }

    before do
      white_pawn_piece.extend(described_class)
      allow(board).to receive(:find).with(coordinate.parse('a5')).and_return(square)
      allow(board).to receive(:piece_for).with(coordinate.parse('a5')).and_return(nil_piece)
      allow(white_piece).to receive(:enemy?).with(nil_piece).and_return(false)
      allow(white_piece).to receive(:enemy?).with(black_piece).and_return(true)
      allow(board).to receive(:find).with(coordinate.parse('c5')).and_return(square)
      allow(board).to receive(:piece_for).with(coordinate.parse('c5')).and_return(black_piece)
    end

    it 'includes takes properly' do
      result = %w[c5].map { |possible_take| coordinate.parse(possible_take) }
      expect(white_pawn_piece.white_takes).to match_array(result)
    end
  end

  context 'when Pawn is black' do
    subject(:black_pawn_piece) { PieceNavigator.new(board_navigator, black_piece) }

    let(:board_navigator) { instance_double(BoardNavigator, board:) }
    let(:board) { instance_double(Board) }
    let(:black_piece) { instance_double(Piece, position: coordinate.parse('g6'), colour: 'black') }
    let(:coordinate) { Coordinate }
    let(:white_piece) { instance_double(Piece, colour: 'white') }
    let(:square) { instance_double(Square) }

    before do
      black_pawn_piece.extend(described_class)
      allow(board).to receive(:find).with(coordinate.parse('f7')).and_return(square)
      allow(board).to receive(:piece_for).with(coordinate.parse('f7')).and_return(white_piece)
      allow(black_piece).to receive(:enemy?).with(white_piece).and_return(true).twice
      allow(board).to receive(:find).with(coordinate.parse('h7')).and_return(square)
      allow(board).to receive(:piece_for).with(coordinate.parse('h7')).and_return(white_piece)
    end

    it 'includes takes properly' do
      result = %w[f7 h7].map { |possible_take| coordinate.parse(possible_take) }
      expect(black_pawn_piece.white_takes).to match_array(result)
    end
  end
end

describe Moves::PawnForward do
  describe '#white_forward' do
    context 'when Pawn is white and not moved' do
      subject(:white_pawn_piece) { PieceNavigator.new(board_navigator, white_piece) }

      let(:board_navigator) { instance_double(BoardNavigator, board:) }
      let(:board) { instance_double(Board) }
      let(:white_piece) { instance_double(Piece, position: coordinate.parse('g6'), colour: 'white') }
      let(:coordinate) { Coordinate }
      let(:square) { instance_double(Square) }

      before do
        white_pawn_piece.extend(described_class)
        allow(white_piece).to receive(:moved?).and_return(false)
        allow(board).to receive(:find).with(coordinate.parse('g7')).and_return(square)
        allow(square).to receive(:occupied?).and_return(false, true)
        allow(board).to receive(:find).with(coordinate.parse('g8')).and_return(square)
        allow(board).to receive(:in_bounds?).with(coordinate.parse('g8')).and_return(true)
      end

      it 'includes moves properly' do
        result = %w[g7].map { |possible_take| coordinate.parse(possible_take) }
        expect(white_pawn_piece.white_forward).to match_array(result)
      end
    end
  end

  describe '#black_forward' do
    context 'when Pawn is black and moved' do
      subject(:black_pawn_piece) { PieceNavigator.new(board_navigator, black_piece) }

      let(:board_navigator) { instance_double(BoardNavigator, board:) }
      let(:board) { instance_double(Board) }
      let(:black_piece) { instance_double(Piece, position: coordinate.parse('c3'), colour: 'black') }
      let(:coordinate) { Coordinate }
      let(:white_piece) { instance_double(Piece, colour: 'white') }
      let(:square) { instance_double(Square) }

      before do
        black_pawn_piece.extend(described_class)
        allow(black_piece).to receive(:moved?).and_return(true)
        allow(board).to receive(:find).with(coordinate.parse('c2')).and_return(square)
        allow(square).to receive(:occupied?).and_return(true)
      end

      it 'includes moves properly' do
        result = []
        expect(black_pawn_piece.black_forward).to match_array(result)
      end
    end
  end
end
# rubocop: enable RSpec/MultipleMemoizedHelpers
