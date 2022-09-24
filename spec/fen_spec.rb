# frozen_string_literal: true

require_relative '../chess'

describe FEN do
  describe '::to_game' do
    subject(:loaded_game) { described_class.new(save).to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

    let(:save) { 'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPPKPPP/RNBQ1BNR b kq - 1 2' }

    context "when loading Game's variables" do
      it 'correctly loads the current player' do
        expect(loaded_game.current_player).to be loaded_game.black_player
      end

      it 'correctly loads the half move clock' do
        half_move_clock = loaded_game.instance_variable_get(:@half_move_clock)
        expect(half_move_clock).to eq(1)
      end

      it 'correctly loads the full move clock' do
        full_move_clock = loaded_game.instance_variable_get(:@full_move_clock)
        expect(full_move_clock).to eq(2)
      end
    end

    context "when loading Board's variables" do
      it 'correctly loads the board' do
        setup = 'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPPKPPP/RNBQ1BNR'
        expect(loaded_game.board.dump_to_fen).to eq(setup)
      end

      it 'correctly loads the castling rights' do
        castling_rights = Hash.new(false)
        castling_rights[:black_queenside] = true
        castling_rights[:black_kingside] = true
        expect(loaded_game.board.castling_rights).to eq(castling_rights)
      end

      it 'correctly loads the en passant pair' do
        pair = loaded_game.board.instance_variable_get(:@en_passant_pair)
        expect(pair).to have_attributes(piece: nil, en_passant_coordinate: nil)
      end
    end
  end
end
