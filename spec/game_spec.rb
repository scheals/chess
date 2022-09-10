# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/board_navigator'
require_relative '../lib/board'

describe Game do
  describe '#pick_piece' do
    context 'when piece belongs to current player' do
      subject(:valid_piece_picking) { described_class.new(player_white, player_black, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:board) { instance_double(Board) }
      let(:white_piece) { instance_double(Piece, colour: :white) }
      let(:player_white) { instance_double(Player, colour: :white) }
      let(:player_black) { instance_double(Player, colour: :black) }

      before do
        allow(board_navigator).to receive(:piece_for).with('a1').and_return(white_piece)
      end

      it 'returns the picked piece' do
        expect(valid_piece_picking.pick_piece('a1')).to be(white_piece)
      end
    end

    context 'when piece does not belong to current player' do
      subject(:invalid_piece_picking) { described_class.new(player_black, player_white, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:board) { instance_double(Board) }
      let(:white_piece) { instance_double(Piece, colour: :white) }
      let(:player_black) { instance_double(Player, colour: :black) }
      let(:player_white) { instance_double(Player, colour: :white) }

      before do
        allow(board_navigator).to receive(:piece_for).with('a2').and_return(white_piece)
      end

      it 'returns nil' do
        expect(invalid_piece_picking.pick_piece('a2')).to be_nil
      end
    end
  end

  describe '#create_move' do
    subject(:game_move) { described_class.new }

    let(:move_system) { class_double(Move) }
    let(:coordinate) { 'a4b6' }

    before do
      allow(move_system).to receive(:parse).with(coordinate)
    end

    it 'sends Move a parse message' do
      game_move.create_move(coordinate, move_system)
      expect(move_system).to have_received(:parse).with(coordinate)
    end
  end

  describe '#ask_for_move' do
    # This test stubs a lot, coupling it tightly to the current implementation. Sadly.
    context 'when move is complete and valid' do
      subject(:good_input) { described_class.new }

      let(:proper_move) { 'a4b5' }

      before do
        allow(good_input).to receive(:gets).and_return(proper_move)
        allow(good_input).to receive(:in_bounds?).with(Move.parse(proper_move)).and_return(true)
        allow(good_input).to receive(:current_player_owns?).with(Move.parse(proper_move).start).and_return(true)
        allow(good_input).to receive(:legal_target?).with(Move.parse(proper_move)).and_return(true)
      end

      it 'returns that move' do
        expect(good_input.ask_for_move).to eq(Move.parse(proper_move))
      end
    end

    context 'when move is invalid' do
      subject(:out_of_bounds_input) { described_class.new }

      let(:improper_move) { 'a9k3' }
      let(:proper_move) { 'a2a4' }

      before do
        out_of_bounds_input.board_navigator.board.setup
        allow(out_of_bounds_input).to receive(:gets).and_return(improper_move, proper_move)
      end

      it 'loops until it gets a correct move' do
        expect(out_of_bounds_input.ask_for_move).to eq(Move.parse(proper_move))
      end
    end
  end

  describe '#in_bounds?' do
    context 'when the full move is in bounds' do
      subject(:game_in_bound_move) { described_class.new(player, player, board_navigator) }

      let(:player) { instance_double(Player) }
      let(:board_navigator) { instance_double(BoardNavigator, board:) }
      let(:board) { instance_double(Board) }
      let(:in_bounds_move) { Move.parse('a1b1') }

      before do
        allow(board).to receive(:in_bounds?).with(in_bounds_move.start).and_return(true)
        allow(board).to receive(:in_bounds?).with(in_bounds_move.target).and_return(true)
      end

      it 'returns true' do
        expect(game_in_bound_move.in_bounds?(in_bounds_move)).to be true
      end
    end

    context 'when the partial move is not in bounds' do
      subject(:game_out_of_bound_move) { described_class.new(player, player, board_navigator) }

      let(:player) { instance_double(Player) }
      let(:board_navigator) { instance_double(BoardNavigator, board:) }
      let(:board) { instance_double(Board) }
      let(:out_of_bounds_move) { Move.parse('a9') }

      before do
        allow(board).to receive(:in_bounds?).with(out_of_bounds_move.start).and_return(false)
      end

      it 'returns false' do
        expect(game_out_of_bound_move.in_bounds?(out_of_bounds_move)).to be false
      end
    end
  end

  describe '#current_player_owns?' do
    context 'when the current player owns the piece' do
      subject(:game_current_player_owns) { described_class.new(player, player, board_navigator) }

      let(:player) { instance_double(Player, colour: 'white') }
      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:move) { Move.parse('a3b3') }
      let(:piece) { instance_double(Piece, colour: 'white') }

      before do
        allow(board_navigator).to receive(:piece_for).with(move.start).and_return(piece)
      end

      it 'returns true' do
        expect(game_current_player_owns.current_player_owns?(move.start)).to be true
      end
    end

    context 'when the current players does not own the piece' do
      subject(:game_current_player_does_not_own) { described_class.new(player, player, board_navigator) }

      let(:player) { instance_double(Player, colour: 'black') }
      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:move) { Move.parse('a6d6') }
      let(:piece) { instance_double(Piece, colour: 'white') }

      before do
        game_current_player_does_not_own.instance_variable_set(:@current_player, player)
        allow(board_navigator).to receive(:piece_for).with(move.start).and_return(piece)
      end

      it 'returns false' do
        expect(game_current_player_does_not_own.current_player_owns?(move.start)).to be false
      end
    end
  end

  describe '#legal_target?' do
    context 'when target is legal' do
      subject(:game_legal_target) { described_class.new(player, player, board_navigator) }

      let(:player) { instance_double(Player, colour: 'black') }
      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:move) { Move.parse('a6d6') }

      before do
        allow(board_navigator).to receive(:moves_for).with(move.start).and_return([Coordinate.parse('d6')])
      end

      it 'returns true' do
        expect(game_legal_target.legal_target?(move)).to be true
      end
    end

    context 'when target is illegal' do
      subject(:game_illegal_target) { described_class.new(player, player, board_navigator) }

      let(:player) { instance_double(Player, colour: 'black') }
      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:move) { Move.parse('b7h2') }

      before do
        allow(board_navigator).to receive(:moves_for).with(move.start).and_return(%w[d6 d3])
      end

      it 'returns false' do
        expect(game_illegal_target.legal_target?(move)).to be false
      end
    end
  end

  describe '#validate_target' do
    context 'when target is legal' do
      subject(:game_valid_move) { described_class.new }

      let(:move) { Move.parse('b7h7') }

      before do
        game_valid_move.board_navigator.board.setup('k7/1r6/8/8/8/8/8/K7')
      end

      it 'returns the move' do
        expect(game_valid_move.validate_target(move)).to be move
      end
    end

    context 'when target is not legal' do
      context 'when move is completed afterwards' do
        subject(:game_target_complete) { described_class.new(player, player, board_navigator) }

        let(:player) { instance_double(Player) }
        let(:board_navigator) { instance_double(BoardNavigator) }
        let(:move) { Move.parse('b7h9') }

        before do
          allow(game_target_complete).to receive(:gets).and_return('b8')
          allow(board_navigator).to receive(:moves_for).with(move.start).and_return([Coordinate.parse('b8')])
        end

        it 'returns that completed move' do
          expect(game_target_complete.validate_target(move)).to eq(Move.parse("#{move.start}b8"))
        end
      end

      context 'when \'q\' is input' do
        subject(:game_target_quit) { described_class.new(player, player, board_navigator) }

        let(:player) { instance_double(Player) }
        let(:board_navigator) { instance_double(BoardNavigator) }
        let(:move) { Move.parse('b7h9') }

        before do
          allow(game_target_quit).to receive(:gets).and_return('q')
          allow(board_navigator).to receive(:moves_for).with(move.start).and_return([Coordinate.parse('b8')])
        end

        it 'returns nil' do
          expect(game_target_quit.validate_target(move)).to be_nil
        end
      end
    end
  end

  describe '#switch_players' do
    subject(:game_switch_players) { described_class.new }

    it 'changes the current player to the other one' do
      expect { game_switch_players.switch_players }.to change(game_switch_players, :current_player)
    end
  end

  describe '#game_over?' do
    context 'when game is still on' do
      subject(:game_continue) { described_class.new }

      before do
        game_continue.board_navigator.board.setup
      end

      it 'returns false' do
        expect(game_continue.game_over?).to be false
      end
    end

    context 'when game is won' do
      subject(:game_won) { described_class.new }

      before do
        game_won.board_navigator.board.setup('R3k3/7R/8/8/8/8/PPPPPPPP/1NBQKBN1')
      end

      it 'returns true' do
        expect(game_won.game_over?).to be true
      end
    end

    context 'when game is tied' do
      subject(:game_tied) { described_class.new }

      before do
        game_tied.board_navigator.board.setup('5bnr/4p1pq/4Qpkr/7p/7P/4P3/PPPP1PP1/RNB1KBNR')
      end

      it 'returns true' do
        expect(game_tied.game_over?).to be true
      end
    end
  end

  describe '#tie?' do
    context 'when it is a stalemate' do
      subject(:stalemate) { described_class.new(player, player, board_navigator) }

      let(:player) { instance_double(Player) }
      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:current_player_colour) { 'white' }

      before do
        allow(player).to receive(:colour).and_return(current_player_colour).twice
        allow(board_navigator).to receive(:stalemate?).with(stalemate.current_player.colour).and_return(true)
      end

      it 'sends BoardNavigator a stalemate? message' do
        stalemate.tie?
        expect(board_navigator).to have_received(:stalemate?).with(current_player_colour)
      end

      it 'returns true' do
        expect(stalemate.tie?).to be true
      end
    end

    context 'when fifty move rule triggers' do
      subject(:fifty_move_rule) { described_class.new }

      before do
        fifty_move_rule.instance_variable_set(:@full_move_clock, 50)
      end

      it 'returns true' do
        expect(fifty_move_rule.tie?).to be true
      end
    end

    context 'when threefold repetition happens' do
      subject(:threefold_repetition) { described_class.new }

      before do
        history = ['2b1nrk1/p2p1npp/1q2p3/2N5/5P2/P5P1/1P3QBP/R3K2R b KQ -',
                   '2b1nrk1/p2p1npp/4p3/1qN5/5P2/P5P1/1P3QBP/R3K2R w KQ -',
                   '2b1nrk1/p2p1npp/4p3/1qN5/5P2/P5P1/1P3Q1P/R3KB1R b KQ -',
                   '2b1nrk1/p2p1npp/2q1p3/2N5/5P2/P5P1/1P3Q1P/R3KB1R w KQ -',
                   '2b1nrk1/p2p1npp/2q1p3/2N5/5P2/P5P1/1P3QBP/R3K2R b KQ -',
                   '2b1nrk1/p2p1npp/4p3/1qN5/5P2/P5P1/1P3QBP/R3K2R w KQ -',
                   '2b1nrk1/p2p1npp/4p3/1qN5/5P2/P5P1/1P3Q1P/R3KB1R b KQ -',
                   '2b1nrk1/p2p1npp/2q1p3/2N5/5P2/P5P1/1P3Q1P/R3KB1R w KQ -',
                   '2b1nrk1/p2p1npp/2q1p3/2N5/5P2/P5P1/1P3QBP/R3K2R b KQ -',
                   '2b1nrk1/p2p1npp/4p3/1qN5/5P2/P5P1/1P3QBP/R3K2R w KQ -']
        threefold_repetition.instance_variable_set(:@board_state_history, history)
      end

      it 'returns true' do
        expect(threefold_repetition.tie?).to be true
      end
    end
  end

  describe '#correct_length?' do
    context 'when the move is correct length' do
      subject(:good_move_game) { described_class.new }

      let(:correct_move) { Move.parse('a3a4') }

      it 'returns true' do
        expect(good_move_game.correct_length?(correct_move)).to be true
      end
    end

    context 'when the move is not the correct length' do
      subject(:bad_move_game) { described_class.new }

      let(:incorrect_move) { Move.parse('a333a4') }

      it 'returns false' do
        expect(bad_move_game.correct_length?(incorrect_move)).to be false
      end
    end
  end

  describe '#promoteable?' do
    context 'when piece at the coordinate is promoteable' do
      subject(:promoteable_game) { described_class.new(player, player, board_navigator) }

      let(:player) { instance_double(Player) }
      let(:board_navigator) { instance_double(BoardNavigator, board:) }
      let(:board) { instance_double(Board) }
      let(:coordinate) { 'a8' }

      before do
        allow(board_navigator).to receive(:promoteable?).with(coordinate).and_return(true)
      end

      it 'returns true' do
        expect(promoteable_game.promoteable?(coordinate)).to be true
      end
    end

    context 'when piece at the coordinate is not promoteable' do
      subject(:nonpromoteable_game) { described_class.new(player, player, board_navigator) }

      let(:player) { instance_double(Player) }
      let(:board_navigator) { instance_double(BoardNavigator, board:) }
      let(:board) { instance_double(Board) }
      let(:coordinate) { 'a8' }

      before do
        allow(board_navigator).to receive(:promoteable?).with(coordinate).and_return(false)
      end

      it 'returns false' do
        expect(nonpromoteable_game.promoteable?(coordinate)).to be false
      end
    end
  end

  describe '#promote' do
    subject(:promoted_game) { described_class.new(player, player, board_navigator) }

    let(:player) { instance_double(Player, name: 'Tester') }
    let(:board_navigator) { instance_double(BoardNavigator) }
    let(:queen) { Queen.new(coordinate, colour: 'black') }
    let(:coordinate) { 'c8' }

    before do
      allow(promoted_game).to receive(:gets).and_return('q')
      allow(board_navigator).to receive(:promote).with(coordinate, 'queen').and_return(queen)
    end

    it 'sends BoardNavigator a promote message' do
      promoted_game.promote(coordinate)
      expect(board_navigator).to have_received(:promote).with(coordinate, 'queen')
    end

    it 'returns piece that was promoted to' do
      expect(promoted_game.promote(coordinate)).to eq(queen)
    end
  end

  describe '#castling?' do
    context 'when it is a castling move' do
      subject(:castling_game) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:king) { instance_double(King) }
      let(:move) { Move.parse('e1c1') }

      before do
        allow(king).to receive(:is_a?).with(King).and_return(true)
        allow(board_navigator).to receive(:piece_for).with(move.target).and_return(king)
      end

      it 'sends BoardNavigator a piece_for message' do
        castling_game.castling?(move)
        expect(board_navigator).to have_received(:piece_for).with(move.target)
      end

      it 'returns true' do
        expect(castling_game.castling?(move)).to be true
      end
    end

    context 'when it is not a castling move' do
      subject(:noncastling_game) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:king) { instance_double(King) }
      let(:move) { Move.new('e1f1') }

      before do
        allow(king).to receive(:is_a?).with(King).and_return(true)
        allow(board_navigator).to receive(:piece_for).with(move.target).and_return(king)
      end

      it 'sends BoardNavigator a piece_for message' do
        noncastling_game.castling?(move)
        expect(board_navigator).to have_received(:piece_for).with(move.target)
      end

      it 'returns false' do
        expect(noncastling_game.castling?(move)).to be false
      end
    end

    context 'when it is not a move done by a King' do
      subject(:rook_castle_attempt_game) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:rook) { instance_double(Rook) }
      let(:move) { Move.new('e1g1') }

      before do
        allow(rook).to receive(:is_a?).with(King).and_return(false)
        allow(board_navigator).to receive(:piece_for).with(move.target).and_return(rook)
      end

      it 'sends BoardNavigator a piece_for message' do
        rook_castle_attempt_game.castling?(move)
        expect(board_navigator).to have_received(:piece_for).with(move.target)
      end

      it 'returns false' do
        expect(rook_castle_attempt_game.castling?(move)).to be false
      end
    end
  end

  describe '#castle' do
    context 'when black is performing queenside castling' do
      subject(:castle_move_game) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:queenside_move) { Move.parse('e8c8') }
      let(:rook_move) { Move.parse('a8d8') }

      before do
        allow(board_navigator).to receive(:move_piece).with(rook_move.start.to_s, rook_move.target.to_s.to_s)
      end

      it 'sends BoardNavigator a move_piece a proper message' do
        castle_move_game.castle(queenside_move)
        expect(board_navigator).to have_received(:move_piece).with(rook_move.start.to_s, rook_move.target.to_s)
      end
    end

    context 'when black is performing kingside castling' do
      subject(:castle_move_game) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:kingside_move) { Move.parse('e8g8') }
      let(:rook_move) { Move.parse('h8f8') }

      before do
        allow(board_navigator).to receive(:move_piece).with(rook_move.start.to_s, rook_move.target.to_s)
      end

      it 'sends BoardNavigator a move_piece a proper message' do
        castle_move_game.castle(kingside_move)
        expect(board_navigator).to have_received(:move_piece).with(rook_move.start.to_s, rook_move.target.to_s)
      end
    end

    context 'when white is performing queenside castling' do
      subject(:castle_move_game) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:queenside_move) { Move.parse('e1c1') }
      let(:rook_move) { Move.parse('a1d1') }

      before do
        allow(board_navigator).to receive(:move_piece).with(rook_move.start.to_s, rook_move.target.to_s)
      end

      it 'sends BoardNavigator a move_piece a proper message' do
        castle_move_game.castle(queenside_move)
        expect(board_navigator).to have_received(:move_piece).with(rook_move.start.to_s, rook_move.target.to_s)
      end
    end

    context 'when white is performing kingside castling' do
      subject(:castle_move_game) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:kingside_move) { Move.parse('e1g1') }
      let(:rook_move) { Move.parse('h1f1') }

      before do
        allow(board_navigator).to receive(:move_piece).with(rook_move.start.to_s, rook_move.target.to_s)
      end

      it 'sends BoardNavigator a move_piece a proper message' do
        castle_move_game.castle(kingside_move)
        expect(board_navigator).to have_received(:move_piece).with(rook_move.start.to_s, rook_move.target.to_s)
      end
    end
  end

  describe '#en_passant_opportunity?' do
    context 'when it creates an en passant opportunity' do
      subject(:en_passant_opportunity) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:move) { Move.parse('a2a4') }
      let(:pawn) { instance_double(Pawn) }

      before do
        allow(pawn).to receive(:is_a?).and_return(Pawn)
        allow(board_navigator).to receive(:piece_for).with(move.target).and_return(pawn)
      end

      it 'sends BoardNavigator a piece_for message' do
        en_passant_opportunity.en_passant_opportunity?(move)
        expect(board_navigator).to have_received(:piece_for).with(move.target).once
      end

      it 'returns true' do
        expect(en_passant_opportunity.en_passant_opportunity?(move)).to be true
      end
    end

    context 'when it does not create an en passant opportunity' do
      subject(:no_en_passant) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:move) { Move.parse('a2a3') }
      let(:pawn) { instance_double(Pawn) }

      before do
        allow(pawn).to receive(:is_a?).and_return(Pawn)
        allow(board_navigator).to receive(:piece_for).with(move.target).and_return(pawn)
      end

      it 'sends BoardNavigator a piece_for message' do
        no_en_passant.en_passant_opportunity?(move)
        expect(board_navigator).to have_received(:piece_for).with(move.target).once
      end

      it 'returns false' do
        expect(no_en_passant.en_passant_opportunity?(move)).to be false
      end
    end
  end

  describe '#send_en_passant_opportunity' do
    subject(:en_passant_game) { described_class.new(player, player, board_navigator) }

    let(:board_navigator) { instance_double(BoardNavigator) }
    let(:player) { instance_double(Player) }
    let(:move) { Move.parse('d7d5') }

    before do
      allow(board_navigator).to receive(:create_en_passant_pair).with(move)
      allow(board_navigator).to receive(:clear_en_passant_pair)
    end

    it 'sends BoardNavigator a create_en_passant_pair message' do
      en_passant_game.send_en_passant_opportunity(move)
      expect(board_navigator).to have_received(:create_en_passant_pair).with(move)
    end

    it 'sends BoardNavigator a clear_en_passant_pair message' do
      en_passant_game.send_en_passant_opportunity(move)
      expect(board_navigator).to have_received(:clear_en_passant_pair)
    end
  end

  describe '#en_passant?' do
    context 'when the move is en passant' do
      subject(:passant_game) { described_class.new }

      let(:passant_opportunity) { Move.parse('c7c5') }
      let(:black_pawn) { passant_game.board_navigator.piece_for('c7') }
      let(:white_pawn) { passant_game.board_navigator.piece_for('d5') }

      before do
        passant_game.board_navigator.board.setup('rnbqkbnr/pppppppp/8/3P4/8/8/PPP1PPPP/RNBQKBNR')
        passant_game.board_navigator.move_piece(passant_opportunity.start, passant_opportunity.target)
        passant_game.send_en_passant_opportunity(passant_opportunity)
        passant_game.board_navigator.move_piece(white_pawn.position, passant_game.board_navigator.en_passant_coordinate)
      end

      it 'returns true' do
        passant_move = Move.new(white_pawn.position,
                                passant_game.board_navigator.en_passant_coordinate)
        expect(passant_game.en_passant?(passant_move)).to be true
      end
    end

    context 'when the move is not en passant' do
      subject(:no_passant_game) { described_class.new }

      let(:black_pawn) { no_passant_game.board_navigator.piece_for('c7') }
      let(:no_passant_opportunity) { Move.parse('c7c6') }
      let(:white_pawn) { no_passant_game.board_navigator.piece_for('d5') }

      before do
        no_passant_game.board_navigator.board.setup('rnbqkbnr/pppppppp/8/3P4/8/8/PPP1PPPP/RNBQKBNR')
        no_passant_game.board_navigator.move_piece(black_pawn.position, no_passant_opportunity.target)
        no_passant_game.board_navigator.move_piece(white_pawn.position, black_pawn.position)
      end

      it 'returns false' do
        no_passant_move = Move.new(white_pawn.position,
                                   black_pawn.position)
        expect(no_passant_game.en_passant?(no_passant_move)).to be false
      end
    end
  end

  describe '#calculate_halfmove_clock' do
    context 'when piece is a Pawn' do
      subject(:halfmove_pawn_reset) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:move) { Move.parse('a2b3') }
      let(:pawn) { instance_double(Pawn) }

      before do
        halfmove_pawn_reset.instance_variable_set(:@half_move_clock, 12)
        allow(board_navigator).to receive(:piece_for).with(move.start).and_return(pawn).once
        allow(pawn).to receive(:is_a?).with(Pawn).and_return(true).once
        allow(board_navigator).to receive(:piece_for).with(move.target).and_return(pawn).once
        allow(pawn).to receive(:real?).and_return(true).once
      end

      it 'sends BoardNavigator a piece_for message twice' do
        halfmove_pawn_reset.calculate_halfmove_clock(move)
        expect(board_navigator).to have_received(:piece_for).twice
      end

      it 'makes @half_move_clock equal to 0' do
        halfmove_pawn_reset.calculate_halfmove_clock(move)
        halfmove_clock = halfmove_pawn_reset.instance_variable_get(:@half_move_clock)
        expect(halfmove_clock).to eq(0)
      end
    end

    context 'when move is a capture' do
      subject(:halfmove_capture_reset) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:move) { Move.parse('a2a6') }
      let(:rook) { instance_double(Rook) }

      before do
        halfmove_capture_reset.instance_variable_set(:@half_move_clock, 12)
        allow(board_navigator).to receive(:piece_for).with(move.start).and_return(rook).once
        allow(rook).to receive(:is_a?).with(Pawn).and_return(false).once
        allow(board_navigator).to receive(:piece_for).with(move.target).and_return(rook).once
        allow(rook).to receive(:real?).and_return(true).once
      end

      it 'sends BoardNavigator a piece_for message twice' do
        halfmove_capture_reset.calculate_halfmove_clock(move)
        expect(board_navigator).to have_received(:piece_for).twice
      end

      it 'makes @half_move_clock equal to 0' do
        halfmove_capture_reset.calculate_halfmove_clock(move)
        halfmove_clock = halfmove_capture_reset.instance_variable_get(:@half_move_clock)
        expect(halfmove_clock).to eq(0)
      end
    end

    context 'when move is not a capture nor made by a Pawn' do
      subject(:halfmove_increment) { described_class.new(player, player, board_navigator) }

      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:player) { instance_double(Player) }
      let(:move) { Move.parse('a2a4') }
      let(:rook) { instance_double(Rook) }

      before do
        halfmove_increment.instance_variable_set(:@half_move_clock, 12)
        allow(board_navigator).to receive(:piece_for).with(move.start).and_return(rook).once
        allow(rook).to receive(:is_a?).with(Pawn).and_return(false).once
        allow(board_navigator).to receive(:piece_for).with(move.target).and_return(rook).once
        allow(rook).to receive(:real?).and_return(false).once
      end

      it 'sends BoardNavigator a piece_for message twice' do
        halfmove_increment.calculate_halfmove_clock(move)
        expect(board_navigator).to have_received(:piece_for).twice
      end

      it 'increments @half_move_clock by 1' do
        expect{ halfmove_increment.calculate_halfmove_clock(move) }.to change{ halfmove_increment.instance_variable_get(:@half_move_clock) }.by(1)
      end
    end
  end

  describe '#to_fen' do
    context 'when converting a starting position' do
      subject(:starting_position) { described_class.new }

      before do
        starting_position.board_navigator.board.setup('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR')
      end

      it 'returns the correct string' do
        string = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
        expect(starting_position.to_fen).to eq(string)
      end
    end
  end
end
