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
        allow(good_input).to receive(:current_player_owns?).with((Move.parse(proper_move)).start).and_return(true)
        allow(good_input).to receive(:legal_target?).with(Move.parse(proper_move)).and_return(true)
      end

      it 'returns that move' do
        expect(good_input.ask_for_move).to eq(Move.parse(proper_move))
      end
    end

    context 'when move is complete but not valid' do
      subject(:out_of_bounds_input) { described_class.new }

      let(:improper_move) { 'a9k3' }

      before do
        allow(out_of_bounds_input).to receive(:gets).and_return(improper_move)
        allow(out_of_bounds_input).to receive(:in_bounds?).with(Move.parse(improper_move)).and_return(false)
      end

      it 'does not return that move' do
        expect(out_of_bounds_input.ask_for_move).not_to eq(Move.parse(improper_move))
      end

      it 'returns nil' do
        expect(out_of_bounds_input.ask_for_move).to be_nil
      end
    end

    context 'when move is incomplete' do
      subject(:incomplete_input) { described_class.new }

      let(:half_move) { 'c3' }

      before do
        allow(incomplete_input).to receive(:gets).and_return(half_move)
      end

      it 'does not return that move' do
        expect(incomplete_input.ask_for_move).not_to eq(Move.parse(half_move))
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
      subject(:game_current_player_owns) { described_class.new(player, player, board_navigator)}

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
      subject(:game_current_player_does_not_own) { described_class.new(player, player, board_navigator)}

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
      subject(:game_legal_target) { described_class.new(player, player, board_navigator)}

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
      subject(:game_illegal_target) { described_class.new(player, player, board_navigator)}

      let(:player) { instance_double(Player, colour: 'black') }
      let(:board_navigator) { instance_double(BoardNavigator) }
      let(:move) { Move.parse('b7h2') }

      before do
        allow(board_navigator).to receive(:moves_for).with(move.start).and_return(['d6', 'd3'])
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
      expect{ game_switch_players.switch_players }.to change { game_switch_players.current_player}
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

    xcontext 'when game is tied' do

      it 'sends a message about a tie' do
      end
      it 'returns true' do
      end
    end
  end
end
