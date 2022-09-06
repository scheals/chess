# frozen_string_literal: true

require_relative '../lib/board_navigator'
require_relative '../lib/board'
require_relative '../lib/navigator_factory'
require_relative '../lib/move'

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
        allow(navigator_factory).to receive(:for).with(navigator, bishop).and_return(bishop_navigator)
        allow(bishop_navigator).to receive(:possible_moves).and_return(%w[b8 c1 c7 d2 d6 e3 e5 g3 g5 h2 h6])
      end

      it 'sends Board a find_piece message twice' do
        navigator.moves_after_collision_for(pieceful_coordinate)
        expect(board).to have_received(:find_piece).with(pieceful_coordinate).twice
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
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), white_king).and_return(white_king_navigator)
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
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), white_king).and_return(white_king_navigator)
        allow(board_copy).to receive(:coordinates).and_return(%w[a3 a4 a7 b4])
        allow(white_king_navigator).to receive(:enemy_coordinates).with(%w[a3 a4 a7 b4]).and_return(['a7'])
        allow(board_copy).to receive(:find_piece).with('a7').and_return(black_rook)
        allow(board_copy).to receive(:find_piece).with('a3').and_return(white_king)
        allow(white_king).to receive(:enemy?).with(white_king).and_return(false)
        allow(board_copy).to receive(:find_piece).with('a4').and_return(white_rook)
        allow(white_king).to receive(:enemy?).with(white_rook).and_return(false)
        allow(white_king).to receive(:enemy?).with(black_rook).and_return(true)
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), black_rook).and_return(black_rook_navigator)
        allow(black_rook_navigator).to receive(:possible_moves).and_return([white_king.position])
      end

      it 'sends the NavigatorFactory a for message with a King' do
        move = 'b4'
        navigate_check.checks_king?(white_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(having_attributes(board: board_copy), white_king)
      end

      it 'sends the NavigatorFactory a for message with enemy pieces' do
        move = 'b4'
        navigate_check.checks_king?(white_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(having_attributes(board: board_copy), black_rook)
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
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), black_king).and_return(black_king_navigator)
        allow(board_copy).to receive(:coordinates).and_return(%w[a1 a7 h8])
        allow(black_king_navigator).to receive(:enemy_coordinates).with(%w[a1 a7 h8]).and_return(['a1'])
        allow(board_copy).to receive(:find_piece).with('h7').and_return(black_rook)
        allow(board_copy).to receive(:find_piece).with('a1').and_return(white_rook)
        allow(white_king).to receive(:enemy?).with(white_rook).and_return(true)
        allow(white_king).to receive(:enemy?).with(black_rook).and_return(false)
        allow(navigator_factory).to receive(:for).with(having_attributes(board: board_copy), white_rook).and_return(white_rook_navigator)
        allow(white_rook_navigator).to receive(:possible_moves).and_return([])
      end

      it 'sends the NavigatorFactory a for message' do
        move = 'a7'
        navigate_checkless.checks_king?(black_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(having_attributes(board: board_copy), black_king)
      end

      it 'sends the NavigatorFactory a for message with enemy pieces' do
        move = 'a7'
        navigate_checkless.checks_king?(black_rook.position, move)
        expect(navigator_factory).to have_received(:for).with(having_attributes(board: board_copy), white_rook)
      end

      it 'returns false' do
        start = 'h7'
        target = 'a7'
        expect(navigate_checkless.checks_king?(start, target)).to be false
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
        board.setup('1k2r3/2N5/r1q1r1N1/6N1/N7/5N2/2r3N1/2N4K')
      end

      it 'just returns correct moves' do
        correct_moves = %w[a4 b5 a8 b6 b7 c7 c5 c4 c3 d7 d6 d5 e4 f3].map { |move| coordinate.parse(move) }
        expect(usual_navigation.moves_for('c6')).to match_array(correct_moves)
      end
    end

    context 'when a move would put own king in check' do
      subject(:checking_move) { described_class.new(board) }

      before do
        board.setup('rnb1k2r/pppqpp1p/5n1b/3p2p1/Q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'does not include those moves' do
        correct_moves = %w[c6 b5 a4].map { |move| coordinate.parse(move) }
        expect(checking_move.moves_for('d7')).to match_array(correct_moves)
      end
    end

    context 'when queenside castling is possible for a king' do
      subject(:queenside_navigation) { described_class.new(board) }

      before do
        board.setup('rnb1k2r/pppqpp1p/5n1b/3p2p1/Q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'includes it as a possibility' do
        correct_moves = %w[d1 d2 c1].map { |move| coordinate.parse(move) }
        expect(queenside_navigation.moves_for('e1')).to match_array(correct_moves)
      end
    end

    context 'when kingside castling is possible for a king' do
      subject(:kingside_navigation) { described_class.new(board) }

      before do
        board.setup('rnb1k2r/pppqpp1p/5n1b/3p2p1/Q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'includes it as a possibility' do
        correct_moves = %w[d8 f8 g8].map { |move| coordinate.parse(move) }
        expect(kingside_navigation.moves_for('e8')).to match_array(correct_moves)
      end
    end

    context 'when queenside castling puts king in check' do
      subject(:illegal_queenside) { described_class.new(board) }

      before do
        board.setup('rnb1k2r/ppp1pp1p/5n1b/3p2p1/q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'does not include it as a possibility' do
        correct_moves = %w[d2].map { |move| coordinate.parse(move) }
        expect(illegal_queenside.moves_for('e1')).to match_array(correct_moves)
      end
    end

    context 'when kingside castling puts king in check' do
      subject(:illegal_kingside) { described_class.new(board) }

      before do
        board.setup('rnb1k2r/ppp1pp1p/5nQb/3p2p1/q1P5/2NPB3/PP2PPPP/R3KBNR')
      end

      it 'does not include it as a possibility' do
        correct_moves = %w[d7 d8 f8].map { |move| coordinate.parse(move) }
        expect(illegal_kingside.moves_for('e8')).to match_array(correct_moves)
      end
    end

    context 'when en passant is possible for a pawn' do
      subject(:en_passant) { described_class.new(board) }

      before do
        board.setup('4k3/8/8/8/3p4/8/4P3/4K3')
        en_passant.move_piece('e2', 'e4')
        en_passant.create_en_passant_coordinate(Move.parse('e2e4'))
      end

      it 'includes it as a possibility' do
        correct_moves = %w[d3 d2 e3].map { |move| coordinate.parse(move) }

        expect(en_passant.moves_for('d4')).to match_array(correct_moves)
      end
    end
  end

  describe '#promoteable?' do
    context 'when piece at the coordinate is promoteable' do
      subject(:promoteable_board) { described_class.new(Board.new) }

      before do
        promoteable_board.board.setup('P3k3/4p3/8/8/8/8/4P3/4K3')
      end

      it 'returns true' do
        coordinate = 'a8'
        expect(promoteable_board.promoteable?(coordinate)).to be true
      end
    end

    context 'when piece at the coordinate is not promoteable' do
      subject(:nonpromoteable_board) { described_class.new(Board.new) }

      before do
        nonpromoteable_board.board.setup('R3k3/4p3/8/8/8/8/4P3/4K3')
      end

      it 'returns false' do
        coordinate = 'a8'
        expect(nonpromoteable_board.promoteable?(coordinate)).to be false
      end
    end
  end

  describe '#win?' do
    context 'when game is still on' do
      subject(:board_continue) { described_class.new(Board.new) }

      before do
        board_continue.board.setup
      end

      it 'returns false' do
        expect(board_continue.win?('black')).to be false
      end
    end

    context 'when game is won' do
      subject(:board_won) { described_class.new(Board.new) }

      before do
        board_won.board.setup('R3k3/7R/8/8/8/8/PPPPPPPP/1NBQKBN1')
      end

      it 'returns true' do
        expect(board_won.win?('white')).to be true
      end
    end
  end

  describe '#move_piece' do
    subject(:moving_navigator) { described_class.new(board) }

    let(:board) { instance_double(Board) }
    let(:start) { 'a2' }
    let(:target) { 'a3' }

    before do
      allow(board).to receive(:move_piece).with(start, target)
    end

    it 'sends board a move_piece message' do
      moving_navigator.move_piece(start, target)
      expect(board).to have_received(:move_piece).with(start, target)
    end
  end

  describe '#promote' do
    subject(:promotion_navigation) { described_class.new(Board.new) }

    let(:coordinate) { 'g8' }
    let(:chosen_piece) { 'queen' }
    let(:promoted_piece) { Queen.new('g8', colour: 'white') }

    before do
      promotion_navigation.board.setup('4k1P1/4p3/8/8/8/8/4P3/4K3')
    end

    it 'promotes a piece to chosen piece' do
      expect(promotion_navigation.promote(coordinate, chosen_piece)).to eq(promoted_piece)
    end

    it 'changes the board' do
      expect { promotion_navigation.promote(coordinate, chosen_piece) }.to change { promotion_navigation.piece_for(coordinate) }
    end
  end

  describe '#create_en_passant_coordinate' do
    subject(:navigate_en_passant) { described_class.new(Board.new) }

    let(:move) { Move.parse('d7d5') }

    before do
      navigate_en_passant.board.setup('rnbqkbnr/ppp1pppp/8/3p4/8/8/PPPPPPPP/RNBQKBNR')
    end

    it 'changes @en_passant_coordinate to the proper coordinate' do
      expect { navigate_en_passant.create_en_passant_coordinate(move) }.to change(navigate_en_passant, :en_passant_coordinate).from(nil).to(move.target.up)
    end
  end

  describe '#clear_en_passant_pair' do
    subject(:clear_en_passant) { described_class.new(Board.new) }

    let(:move) { Move.parse('g7g5') }

    before do
      clear_en_passant.board.setup('rnbqkbnr/pppppp1p/8/6p1/8/8/PPPPPPPP/RNBQKBNR')
      clear_en_passant.create_en_passant_coordinate(move)
    end

    it 'changes @en_passant_coordinate to nil' do
      expect { clear_en_passant.clear_en_passant_pair }.to change(clear_en_passant, :en_passant_coordinate).to(nil)
    end
  end
end
