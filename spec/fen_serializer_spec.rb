# frozen_string_literal: true

require_relative '../chess'

describe FENSerializer do
  describe '#game_to_fen' do
    subject(:usual_game) { described_class.new(game) }

    let(:game) { FEN.new('k7/1R6/8/8/8/8/8/7r w - - 0 1').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

    it 'returns proper FEN representation' do
      expected = 'k7/1R6/8/8/8/8/8/7r w - - 0 1'
      expect(usual_game.game_to_fen).to eq(expected)
    end
  end

  describe '#record_en_passant_coordinate' do
    context 'when there is a coordinate to be recorded' do
      subject(:en_passant) { described_class.new(game) }

      let(:game) { FEN.new('k7/1R6/8/8/8/8/8/7r w - a3 0 1').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns a proper string of it' do
        string = 'a3'
        expect(en_passant.record_en_passant_coordinate).to eq(string)
      end
    end

    context 'when there is no coordiante to be recorded' do
      subject(:no_en_passant) { described_class.new(game) }

      let(:game) { FEN.new('rnbqkb1r/ppp1pppp/3p4/3nP3/3P4/5N2/PPP2PPP/RNBQKB1R b KQkq - 1 4').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns a proper string of it' do
        string = '-'
        expect(no_en_passant.record_en_passant_coordinate).to eq(string)
      end
    end
  end

  describe '#queenside_castling_rights?' do
    context 'when it has those rights' do
      subject(:queenside_castling) { described_class.new(game) }

      let(:game) { FEN.new('rnbqkb1r/ppp1pppp/3p4/3nP3/3P4/5N2/PPP2PPP/RNBQKB1R b KQkq - 1 4').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns true' do
        colour = 'white'
        expect(queenside_castling.queenside_castling_rights?(colour)).to be true
      end
    end

    context 'when it does not have those rights because of missing queenside rook' do
      subject(:queenside_castling) { described_class.new(game) }

      let(:game) { FEN.new('1nbqkb1r/ppp1pppp/3p4/3nP3/3P4/5N2/PPP2PPP/RNBQKB1R b KQk - 1 4').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns false' do
        colour = 'black'
        expect(queenside_castling.queenside_castling_rights?(colour)).to be false
      end
    end

    context 'when it does not have those rights because of loaded state' do
      subject(:loaded_queenside) { described_class.new(game)}

      let(:game) { FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kk - 0 1').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns false' do
        colour = 'black'
        expect(loaded_queenside.queenside_castling_rights?(colour)).to be false
      end
    end
  end

  describe '#kingside_castling_rights?' do
    context 'when it has those rights' do
      subject(:kingside_castling) { described_class.new(game) }

      let(:game) { FEN.new('1nbqkb2/ppp1pppp/3p4/3nP3/3P4/5N2/PPP2PPP/RNBQKB1R b KQ - 1 4').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns true' do
        colour = 'white'
        expect(kingside_castling.kingside_castling_rights?(colour)).to be true
      end
    end

    context 'when it does not have those rights because of missing kingside rook' do
      subject(:kingside_castling) { described_class.new(game) }

      let(:game) { FEN.new('1nbqkb2/ppp1pppp/3p4/3nP3/3P4/5N2/PPP2PPP/RNBQKB1R b KQ - 1 4').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns false' do
        colour = 'black'
        expect(kingside_castling.kingside_castling_rights?(colour)).to be false
      end
    end

    context 'when it does not have those rights because of loaded state' do
      subject(:loaded_kingside) { described_class.new(game) }

      let(:game) { FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w kQq - 0 1').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns false' do
        colour = 'white'
        expect(loaded_kingside.kingside_castling_rights?(colour)).to be false
      end
    end
  end

  describe '#record_castling_rights' do
    context 'when everyone has full castling rights' do
      subject(:full_castling_rights) { described_class.new(game) }

      let(:game) { FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns a proper string' do
        string = 'KQkq'
        expect(full_castling_rights.record_castling_rights).to eq(string)
      end
    end

    context 'when only black has castling rights' do
      subject(:black_castling_rights) { described_class.new(game) }

      let(:game) { FEN.new('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/1NBQKBN1 w kq - 0 1').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns a proper string' do
        string = 'kq'
        expect(black_castling_rights.record_castling_rights).to eq(string)
      end
    end

    context 'when no one has castling rights' do
      subject(:no_castling_rights) { described_class.new(game) }

      let(:game) { FEN.new('1nbqkbn1/pppppppp/8/8/8/8/PPPPPPPP/1NBQKBN1 w - - 0 1').to_game(Player.new('White', 'white'), Player.new('Black', 'black')) }

      it 'returns a proper string' do
        string = '-'
        expect(no_castling_rights.record_castling_rights).to eq(string)
      end
    end
  end
end
