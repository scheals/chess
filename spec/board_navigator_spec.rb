# frozen_string_literal: true

require_relative '../lib/board_navigator'
require_relative '../lib/board'
require_relative '../lib/navigator_factory'
require_relative '../lib/move'
require_relative '../lib/player'

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
        allow(board).to receive(:piece_for).with(pieceful_coordinate).and_return(bishop).twice
        allow(navigator_factory).to receive(:for).with(navigator, bishop).and_return(bishop_navigator)
        allow(bishop_navigator).to receive(:possible_moves).and_return(%w[b8 c1 c7 d2 d6 e3 e5 g3 g5 h2 h6])
      end

      it 'sends Board a piece_for message twice' do
        navigator.moves_after_collision_for(pieceful_coordinate)
        expect(board).to have_received(:piece_for).with(pieceful_coordinate).twice
      end

      it 'sends NavigatorFactory a for message' do
        navigator.moves_after_collision_for(pieceful_coordinate)
        expect(navigator_factory).to have_received(:for).with(navigator, bishop)
      end

      it 'sends NavigatorPiece a possible_moves message' do
        navigator.moves_after_collision_for(pieceful_coordinate)
        expect(bishop_navigator).to have_received(:possible_moves)
      end

      it 'returns correct moves' do
        correct_moves = %w[b8 c1 c7 d2 d6 e3 e5 g3 g5 h2 h6].map { |move| Coordinate.parse(move) }
        expect(navigator.moves_after_collision_for(pieceful_coordinate)).to eq(correct_moves)
      end
    end

    context 'when piece is not found' do
      subject(:navigator) { described_class.new(board, navigator_factory) }

      let(:navigator_factory) { class_double(NavigatorFactory) }
      let(:empty_coordinate) { 'a1' }
      let(:board) { instance_double(Board) }

      before do
        allow(board).to receive(:piece_for).with(empty_coordinate).and_return(nil)
        allow(navigator_factory).to receive(:for)
      end

      it 'sends Board a piece_for message' do
        navigator.moves_after_collision_for(empty_coordinate)
        expect(board).to have_received(:piece_for).with(empty_coordinate)
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
        allow(navigator_factory).to receive(:for).with(checking_check, king).and_return(king_navigator)
        allow(king_navigator).to receive(:instance_of?).with(KingNavigator).and_return(true)
        allow(board).to receive(:coordinates).and_return(%w[a1 a2])
        allow(king).to receive(:position).and_return('a1')
        allow(king_navigator).to receive(:enemy_coordinates).and_return([])
      end

      it 'sends NavigatorFactory a for message with a King if KingNavigator was not passed in' do
        checking_check.under_check?(king)
        expect(navigator_factory).to have_received(:for).with(checking_check, king)
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
        board.setup_from_fen('r6K/8/8/r7/8/8/8/8')
      end

      it 'returns true' do
        king = board.piece_for('h8')
        expect(navigate_check.under_check?(king)).to be true
      end
    end

    context 'when King is not under check' do
      subject(:navigate_checkless) { described_class.new(board) }

      let(:board) { Board.new }

      before do
        board.setup_from_fen('k7/1R6/8/8/8/8/8/7r')
      end

      it 'returns false' do
        king = board.piece_for('a8')
        expect(navigate_checkless.under_check?(king)).to be false
      end
    end
  end

  describe '#move_checks_own_king?' do
    let(:navigator_factory) { class_double(NavigatorFactory) }
    let(:board) { instance_double(Board) }
    let(:board_copy) { instance_double(Board) }
    let(:white_piece) { instance_double(Piece, position: Coordinate.parse('a1'), colour: 'white') }
    let(:white_king) { instance_double(King, position: Coordinate.parse('a3'), colour: 'white') }
    let(:black_king) { instance_double(King, position: Coordinate.parse('h8'), colour: 'black') }

    context 'when called' do
      subject(:king_checking) { described_class.new(board, navigator_factory) }

      let(:white_king_navigator) { instance_double(KingNavigator, board:, piece: white_king) }

      before do
        move = 'a2'
        allow(board).to receive(:copy).and_return(board_copy)
        allow(board_copy).to receive(:move_piece).with(white_piece.position, move)
        allow(board_copy).to receive(:king_for).with(move).and_return(white_king)
        allow(board_copy).to receive(:piece_for).with(move).and_return(white_piece)
        allow(white_piece).to receive(:ally?).with(white_king).and_return(true)
        allow(white_piece).to receive(:ally?).with(black_king).and_return(false)
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), white_king).and_return(white_king_navigator)
        none = []
        allow(white_king_navigator).to receive(:enemy_coordinates).and_return(none)
        allow(board_copy).to receive(:coordinates).and_return(none)
      end

      it 'always sends Board a copy message' do
        move = 'a2'
        king_checking.move_checks_own_king?(white_piece.position, move)
        expect(board).to have_received(:copy)
      end

      it 'always sends the copy of Board a move_piece message' do
        move = 'a2'
        king_checking.move_checks_own_king?(white_piece.position, move)
        expect(board_copy).to have_received(:move_piece).with(white_piece.position, move)
      end

      it 'always sends the copy of Board a king_for message' do
        move = 'a2'
        king_checking.move_checks_own_king?(white_piece.position, move)
        expect(board_copy).to have_received(:king_for).with(move)
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
        allow(board_copy).to receive(:king_for).with(move).and_return(white_king)
        allow(board_copy).to receive(:piece_for).with(move).and_return(white_rook).thrice
        allow(white_rook).to receive(:ally?).and_return(true, false)
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), white_king).and_return(white_king_navigator)
        allow(board_copy).to receive(:coordinates).and_return(%w[a3 a4 a7 b4])
        allow(white_king_navigator).to receive(:enemy_coordinates).with(%w[a3 a4 a7 b4]).and_return(['a7'])
        allow(board_copy).to receive(:piece_for).with('a7').and_return(black_rook)
        allow(board_copy).to receive(:piece_for).with('a3').and_return(white_king)
        allow(white_king).to receive(:enemy?).with(white_king).and_return(false)
        allow(board_copy).to receive(:piece_for).with('a4').and_return(white_rook)
        allow(white_king).to receive(:enemy?).with(white_rook).and_return(false)
        allow(white_king).to receive(:enemy?).with(black_rook).and_return(true)
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), black_rook).and_return(black_rook_navigator)
        allow(black_rook_navigator).to receive(:possible_moves).and_return([white_king.position])
      end

      it 'sends the NavigatorFactory a for message with a King' do
        move = 'b4'
        navigate_check.move_checks_own_king?(white_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(having_attributes(board: board_copy), white_king)
      end

      it 'sends the NavigatorFactory a for message with enemy pieces' do
        move = 'b4'
        navigate_check.move_checks_own_king?(white_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(having_attributes(board: board_copy), black_rook)
      end

      it 'returns true' do
        start = 'a4'
        target = 'b4'
        expect(navigate_check.move_checks_own_king?(start, target)).to be true
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
        allow(board_copy).to receive(:king_for).with(move).and_return(black_king)
        allow(board_copy).to receive(:piece_for).with(move).and_return(black_rook).exactly(4).times
        allow(black_rook).to receive(:ally?).and_return(false, true)
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), black_king).and_return(black_king_navigator)
        allow(board_copy).to receive(:coordinates).and_return(%w[a1 a7 h8])
        allow(black_king_navigator).to receive(:enemy_coordinates).with(%w[a1 a7 h8]).and_return(['a1'])
        allow(board_copy).to receive(:piece_for).with('h7').and_return(black_rook)
        allow(board_copy).to receive(:piece_for).with('a1').and_return(white_rook)
        allow(white_king).to receive(:enemy?).with(white_rook).and_return(true)
        allow(white_king).to receive(:enemy?).with(black_rook).and_return(false)
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), white_rook).and_return(white_rook_navigator)
        allow(white_rook_navigator).to receive(:possible_moves).and_return([])
      end

      it 'sends the NavigatorFactory a for message' do
        move = 'a7'
        navigate_checkless.move_checks_own_king?(black_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(having_attributes(board: board_copy), black_king)
      end

      it 'sends the NavigatorFactory a for message with enemy pieces' do
        move = 'a7'
        navigate_checkless.move_checks_own_king?(black_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(having_attributes(board: board_copy), white_rook)
      end

      it 'returns false' do
        start = 'h7'
        target = 'a7'
        expect(navigate_checkless.move_checks_own_king?(start, target)).to be false
      end
    end
  end
  # rubocop: enable RSpec/MultipleMemoizedHelpers

  describe '#moves_for' do
    let(:board) { Board.new }
    let(:coordinate) { Coordinate }

    context 'when piece has no special considerations' do
      subject(:usual_navigation) { described_class.new(board) }

      before do
        board.setup_from_fen('1k2r3/2N5/r1q1r1N1/6N1/N7/5N2/2r3N1/2N4K')
      end

      it 'just returns correct moves' do
        correct_moves = %w[a4 b5 a8 b6 b7 c7 c5 c4 c3 d7 d6 d5 e4 f3].map { |move| coordinate.parse(move) }
        expect(usual_navigation.moves_for('c6')).to match_array(correct_moves)
      end
    end

    context 'when a move would put own king in check' do
      subject(:checking_move) { described_class.new(board) }

      before do
        board.setup_from_fen('rnb1k2r/pppqpp1p/5n1b/3p2p1/Q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'does not include those moves' do
        correct_moves = %w[c6 b5 a4].map { |move| coordinate.parse(move) }
        expect(checking_move.moves_for('d7')).to match_array(correct_moves)
      end
    end

    context 'when queenside castling is possible for a king' do
      subject(:queenside_navigation) { described_class.new(board) }

      before do
        board.setup_from_fen('rnb1k2r/pppqpp1p/5n1b/3p2p1/Q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'includes it as a possibility' do
        correct_moves = %w[d1 d2 c1].map { |move| coordinate.parse(move) }
        expect(queenside_navigation.moves_for('e1')).to match_array(correct_moves)
      end
    end

    context 'when kingside castling is possible for a king' do
      subject(:kingside_navigation) { described_class.new(board) }

      before do
        board.setup_from_fen('rnb1k2r/pppqpp1p/5n1b/3p2p1/Q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'includes it as a possibility' do
        correct_moves = %w[d8 f8 g8].map { |move| coordinate.parse(move) }
        expect(kingside_navigation.moves_for('e8')).to match_array(correct_moves)
      end
    end

    context 'when queenside castling puts king in check' do
      subject(:illegal_queenside) { described_class.new(board) }

      before do
        board.setup_from_fen('rnb1k2r/ppp1pp1p/5n1b/3p2p1/q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'does not include it as a possibility' do
        correct_moves = %w[d2].map { |move| coordinate.parse(move) }
        expect(illegal_queenside.moves_for('e1')).to match_array(correct_moves)
      end
    end

    context 'when kingside castling puts king in check' do
      subject(:illegal_kingside) { described_class.new(board) }

      before do
        board.setup_from_fen('rnb1k2r/ppp1pp1p/5nQb/3p2p1/q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'does not include it as a possibility' do
        correct_moves = %w[d7 d8 f8].map { |move| coordinate.parse(move) }
        expect(illegal_kingside.moves_for('e8')).to match_array(correct_moves)
      end
    end

    context 'when en passant is possible for a pawn' do
      subject(:en_passant) { described_class.new(board) }

      before do
        board.setup_from_fen('4k3/8/8/8/3p4/8/4P3/4K3')
        en_passant.board.move_piece('e2', 'e4')
        board.create_en_passant_pair(Move.parse('e2e4'))
      end

      it 'includes it as a possibility' do
        correct_moves = %w[d3 d2 e3].map { |move| coordinate.parse(move) }

        expect(en_passant.moves_for('d4')).to match_array(correct_moves)
      end
    end

    context 'when en passant is possible for a pawn thanks to a load' do
      subject(:en_passant) { described_class.new(board) }

      let(:colour) { 'black' }
      let(:en_passant_coordinate) { 'e3' }

      before do
        board.setup_from_fen('4k3/8/8/8/3pP3/8/8/4K3')
        board.load_en_passant_coordinate(en_passant_coordinate, colour)
      end

      it 'includes it as a possibility' do
        correct_moves = %w[d3 d2 e3].map { |move| coordinate.parse(move) }
        expect(en_passant.moves_for('d4')).to match_array(correct_moves)
      end
    end
  end

  describe '#win?' do
    context 'when game is still on' do
      subject(:board_continue) { described_class.new(Board.new) }

      before do
        board_continue.board.setup_from_fen
      end

      it 'returns false' do
        expect(board_continue.win?('black')).to be false
      end
    end

    context 'when game is won' do
      subject(:board_won) { described_class.new(Board.new) }

      before do
        board_won.board.setup_from_fen('R3k3/7R/8/8/8/8/PPPPPPPP/1NBQKBN1')
      end

      it 'returns true' do
        expect(board_won.win?('white')).to be true
      end
    end
  end
end
