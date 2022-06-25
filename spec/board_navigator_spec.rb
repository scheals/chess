# frozen_string_literal: true

require_relative '../lib/board_navigator'
require_relative '../lib/board'
require_relative '../lib/navigator_factory'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

describe BoardNavigator do
  # rubocop: disable RSpec/MultipleMemoizedHelpers
  describe '#moves_after_collision_for' do
    let(:coordinate) { Coordinate }

    context 'when piece is found' do
      subject(:navigator) { described_class.new(board, navigator_factory) }

      let(:bishop) { instance_double(Bishop, position: coordinate.parse('f4'), colour: 'white') }
      let(:board) { instance_double(Board) }
      let(:navigator_factory) { class_double(NavigatorFactory) }
      let(:bishop_navigator) { instance_double(BishopNavigator, board:, piece: bishop) }
      let(:pieceful_coordinate) { 'f4' }

      before do
        allow(board).to receive(:find_piece).with(pieceful_coordinate).and_return(bishop).twice
        allow(navigator_factory).to receive(:for).with(board, bishop).and_return(bishop_navigator)
        allow(bishop_navigator).to receive(:possible_moves).and_return(%w[b8 c1 c7 d2 d6 e3 e5 g3 g5 h2 h6])
      end

      it 'sends Board a find_piece message twice' do
        navigator.moves_after_collision_for(pieceful_coordinate)
        expect(board).to have_received(:find_piece).with(pieceful_coordinate).twice
      end

      it 'sends NavigatorFactory a for message' do
        navigator.moves_after_collision_for(pieceful_coordinate)
        expect(navigator_factory).to have_received(:for).with(board, bishop)
      end

      it 'sends NavigatorPiece a possible_moves message' do
        navigator.moves_after_collision_for(pieceful_coordinate)
        expect(bishop_navigator).to have_received(:possible_moves)
      end

      it 'returns correct moves' do
        correct_moves = %w[b8 c1 c7 d2 d6 e3 e5 g3 g5 h2 h6]
        expect(navigator.moves_after_collision_for(pieceful_coordinate)).to eq(correct_moves)
      end
    end

    context 'when piece is not found' do
      subject(:navigator) { described_class.new(board, navigator_factory) }

      let(:navigator_factory) { class_double(NavigatorFactory) }
      let(:empty_coordinate) { 'a1' }
      let(:board) { instance_double(Board) }

      before do
        allow(board).to receive(:find_piece).with(empty_coordinate).and_return(nil)
        allow(navigator_factory).to receive(:for)
      end

      it 'sends Board a find_piece message' do
        navigator.moves_after_collision_for(empty_coordinate)
        expect(board).to have_received(:find_piece).with(empty_coordinate)
      end

      it "doesn't send NavigatorFactory a message" do
        navigator.moves_after_collision_for(empty_coordinate)
        expect(navigator_factory).not_to have_received(:for)
      end

      it 'returns nil' do
        expect(navigator.moves_after_collision_for(empty_coordinate)).to be_nil
      end
    end
  end

  describe '#under_check?' do
    context 'when called' do
      subject(:checking_check) { described_class.new(board, navigator_factory) }

      let(:navigator_factory) { class_double(NavigatorFactory) }
      let(:board) { instance_double(Board) }
      let(:king) { instance_double(King) }
      let(:king_navigator) { instance_double(KingNavigator) }

      before do
        allow(king).to receive(:instance_of?).with(KingNavigator).and_return(false)
        allow(navigator_factory).to receive(:for).with(board, king).and_return(king_navigator)
        allow(king_navigator).to receive(:instance_of?).with(KingNavigator).and_return(true)
        allow(board).to receive(:coordinates).and_return(%w[a1 a2])
        allow(king).to receive(:position).and_return('a1')
        allow(king_navigator).to receive(:enemy_coordinates).and_return([])
      end

      it 'sends NavigatorFactory a for message with a King if KingNavigator was not passed in' do
        checking_check.under_check?(king)
        expect(navigator_factory).to have_received(:for).with(board, king)
      end

      it 'does not send NavigatorFactory a for message if KingNavigator was passed in' do
        checking_check.under_check?(king_navigator)
        expect(navigator_factory).not_to have_received(:for)
      end
    end

    context 'when King is under check' do
      subject(:navigate_check) { described_class.new(board) }

      let(:board) { Board.new }

      before do
        board.setup('r6K/8/8/r7/8/8/8/8')
      end

      it 'returns true' do
        king = board.find_piece('h8')
        expect(navigate_check.under_check?(king)).to be true
      end
    end

    context 'when King is not under check' do
      subject(:navigate_checkless) { described_class.new(board) }

      let(:board) { Board.new }

      before do
        board.setup('k7/1R6/8/8/8/8/8/7r')
      end

      it 'returns false' do
        king = board.find_piece('a8')
        expect(navigate_checkless.under_check?(king)).to be false
      end
    end
  end
  # rubocop: enable RSpec/MultipleMemoizedHelpers

  describe '#king_for' do
    subject(:navigating_for_a_king) { described_class.new(board, navigator_factory) }

    let(:board) { instance_double(Board) }
    let(:navigator_factory) { class_double(NavigatorFactory) }
    let(:white_king) { instance_double(King, position: 'a1', colour: 'white') }
    let(:black_king) { instance_double(King, position: 'a2', colour: 'black') }
    let(:white_piece) { instance_double(Piece, position: 'a3', colour: 'white') }

    before do
      allow(board).to receive(:find_kings).and_return([white_king, black_king])
      allow(board).to receive(:find_piece).with('a3').and_return(white_piece)
      allow(white_piece).to receive(:ally?).with(white_king).and_return true
      allow(white_piece).to receive(:ally?).with(black_king).and_return false
    end

    it 'returns allied King of a piece' do
      coordinate = 'a3'
      expect(navigating_for_a_king.king_for(coordinate)).to eq(white_king)
    end
  end

  # rubocop: disable RSpec/MultipleMemoizedHelpers
  describe '#checks_king?' do
    let(:navigator_factory) { class_double(NavigatorFactory) }
    let(:board) { instance_double(Board) }
    let(:board_copy) { instance_double(Board) }
    let(:white_piece) { instance_double(Piece, position: 'a1', colour: 'white') }
    let(:white_king) { instance_double(King, position: 'a3', colour: 'white') }
    let(:black_king) { instance_double(King, position: 'h8', colour: 'black') }

    context 'when called' do
      subject(:king_checking) { described_class.new(board, navigator_factory) }

      let(:white_king_navigator) { instance_double(KingNavigator, board:, piece: white_king) }

      before do
        move = 'a2'
        allow(board).to receive(:copy).and_return(board_copy)
        allow(board_copy).to receive(:move_piece).with(white_piece.position, move)
        allow(board_copy).to receive(:find_kings).and_return([white_king, black_king])
        allow(board_copy).to receive(:find_piece).with(move).and_return(white_piece)
        allow(white_piece).to receive(:ally?).with(white_king).and_return(true)
        allow(white_piece).to receive(:ally?).with(black_king).and_return(false)
        allow(navigator_factory).to receive(:for).with(board_copy, white_king).and_return(white_king_navigator)
        none = []
        allow(white_king_navigator).to receive(:enemy_coordinates).and_return(none)
        allow(board_copy).to receive(:coordinates).and_return(none)
      end

      it 'always sends Board a copy message' do
        move = 'a2'
        king_checking.checks_king?(white_piece.position, move)
        expect(board).to have_received(:copy)
      end

      it 'always sends the copy of Board a move_piece message' do
        move = 'a2'
        king_checking.checks_king?(white_piece.position, move)
        expect(board_copy).to have_received(:move_piece).with(white_piece.position, move)
      end

      it 'always sends the copy of Board a find_kings message' do
        move = 'a2'
        king_checking.checks_king?(white_piece.position, move)
        expect(board_copy).to have_received(:find_kings)
      end
    end

    context 'when it puts own King in check' do
      subject(:navigate_check) { described_class.new(board, navigator_factory) }

      let(:white_king_navigator) { instance_double(KingNavigator, board:, piece: white_king) }
      let(:black_rook) { instance_double(Rook, position: 'a7', colour: 'black') }
      let(:black_rook_navigator) { instance_double(RookNavigator, board:, piece: black_rook) }
      let(:white_rook) { instance_double(Rook, position: 'a4', colour: 'white') }
      let(:white_rook_navigator) { instance_double(RookNavigator, board:, piece: white_rook) }

      before do
        move = 'b4'
        allow(board).to receive(:copy).and_return(board_copy)
        allow(board_copy).to receive(:move_piece).with(white_rook.position, move)
        allow(board_copy).to receive(:find_kings).and_return([white_king, black_king])
        allow(board_copy).to receive(:find_piece).with(move).and_return(white_rook).thrice
        allow(white_rook).to receive(:ally?).and_return(true, false)
        allow(navigator_factory).to receive(:for).with(board_copy, white_king).and_return(white_king_navigator)
        allow(board_copy).to receive(:coordinates).and_return(%w[a3 a4 a7 b4])
        allow(white_king_navigator).to receive(:enemy_coordinates).with(%w[a3 a4 a7 b4]).and_return(['a7'])
        allow(board_copy).to receive(:find_piece).with('a7').and_return(black_rook)
        allow(board_copy).to receive(:find_piece).with('a3').and_return(white_king)
        allow(white_king).to receive(:enemy?).with(white_king).and_return(false)
        allow(board_copy).to receive(:find_piece).with('a4').and_return(white_rook)
        allow(white_king).to receive(:enemy?).with(white_rook).and_return(false)
        allow(white_king).to receive(:enemy?).with(black_rook).and_return(true)
        allow(navigator_factory).to receive(:for).with(board_copy, black_rook).and_return(black_rook_navigator)
        allow(black_rook_navigator).to receive(:possible_moves).and_return([white_king.position])
      end

      it 'sends the NavigatorFactory a for message with a King' do
        move = 'b4'
        navigate_check.checks_king?(white_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(board_copy, white_king)
      end

      it 'sends the NavigatorFactory a for message with enemy pieces' do
        move = 'b4'
        navigate_check.checks_king?(white_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(board_copy, black_rook)
      end

      it 'returns true' do
        start = 'a4'
        target = 'b4'
        expect(navigate_check.checks_king?(start, target)).to be true
      end
    end

    context 'when it does not put own King in check' do
      subject(:navigate_checkless) { described_class.new(board, navigator_factory) }

      let(:black_king_navigator) { instance_double(KingNavigator, board:, piece: black_king) }
      let(:white_rook) { instance_double(Rook, position: 'a1', colour: 'white') }
      let(:white_rook_navigator) { instance_double(RookNavigator, board:, piece: white_rook) }
      let(:black_rook) { instance_double(Rook, position: 'h7', colour: 'black') }
      let(:black_rook_navigator) { instance_double(RookNavigator, board:, piece: black_rook) }

      before do
        move = 'a7'
        allow(board).to receive(:copy).and_return(board_copy)
        allow(board_copy).to receive(:move_piece).with(black_rook.position, move)
        allow(board_copy).to receive(:find_kings).and_return([white_king, black_king])
        allow(board_copy).to receive(:find_piece).with(move).and_return(black_rook).exactly(4).times
        allow(black_rook).to receive(:ally?).and_return(false, true)
        allow(navigator_factory).to receive(:for).with(board_copy, black_king).and_return(black_king_navigator)
        allow(board_copy).to receive(:coordinates).and_return(%w[a1 a7 h8])
        allow(black_king_navigator).to receive(:enemy_coordinates).with(%w[a1 a7 h8]).and_return(['a1'])
        allow(board_copy).to receive(:find_piece).with('h7').and_return(black_rook)
        allow(board_copy).to receive(:find_piece).with('a1').and_return(white_rook)
        allow(white_king).to receive(:enemy?).with(white_rook).and_return(true)
        allow(white_king).to receive(:enemy?).with(black_rook).and_return(false)
        allow(navigator_factory).to receive(:for).with(board_copy, white_rook).and_return(white_rook_navigator)
        allow(white_rook_navigator).to receive(:possible_moves).and_return([])
      end

      it 'sends the NavigatorFactory a for message' do
        move = 'a7'
        navigate_checkless.checks_king?(black_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(board_copy, black_king)
      end

      it 'sends the NavigatorFactory a for message with enemy pieces' do
        move = 'a7'
        navigate_checkless.checks_king?(black_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(board_copy, white_rook)
      end

      it 'returns false' do
        start = 'h7'
        target = 'a7'
        expect(navigate_checkless.checks_king?(start, target)).to be false
      end
    end
  end
  # rubocop: enable RSpec/MultipleMemoizedHelpers
end
