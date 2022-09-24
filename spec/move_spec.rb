# frozen_string_literal: true

require_relative '../chess'

describe Move do
  describe '@parse' do
    context 'when it is given a Move' do
      subject(:no_parse) { described_class }

      let(:ready_move) { described_class.new('a1b4') }

      it 'returns that Move' do
        expect(no_parse.parse(ready_move)).to be(ready_move)
      end
    end

    context 'when it is given a string with length of two' do
      subject(:two_parse) { described_class }

      let(:single_coordinate) { 'a1' }

      it 'creates new Move with @start' do
        expect(two_parse.parse(single_coordinate)).to have_attributes(start: Coordinate.parse('a1'))
      end
    end

    context 'when it is given given a string with length of four' do
      subject(:four_parse) { described_class }

      let(:double_coordinate) { 'h8d4' }

      it 'creates new Move with @start and @target' do
        expect(four_parse.parse(double_coordinate)).to have_attributes(start: Coordinate.parse('h8'), target: Coordinate.parse('d4'))
      end
    end

    context 'when it is given too short or too long of a string' do
      subject(:nil_parse) { described_class }

      let(:long_coordinate) { 'a11b99' }

      it 'returns nil' do
        expect(nil_parse.parse(long_coordinate)).to be_nil
      end
    end
  end

  describe '#full_move?' do
    context 'when the move has a start and a target' do
      subject(:full_move) { described_class.parse('a4b4') }

      it 'returns true' do
        expect(full_move.full_move?).to be true
      end
    end

    context 'when the move does not have both start and a target' do
      subject(:partial_move) { described_class.parse('b4') }

      it 'returns false' do
        expect(partial_move.full_move?).to be false
      end
    end
  end

  describe '#partial_move?' do
    context 'when the move has a start only' do
      subject(:partial_move) { described_class.parse('a4') }

      it 'returns true' do
        expect(partial_move.partial_move?).to be true
      end
    end

    context 'when the move has more than just start' do
      subject(:full_move) { described_class.parse('a4b4') }

      it 'returns false' do
        expect(full_move.partial_move?).to be false
      end
    end
  end

  describe '#in_bounds?' do
    context 'when it is a full move' do
      context 'when it is in bounds' do
        subject(:full_in_bounds) { described_class.parse('a1b1') }

        let(:board) { instance_double(Board) }

        before do
          allow(board).to receive(:in_bounds?).with(full_in_bounds.start).and_return(true)
          allow(board).to receive(:in_bounds?).with(full_in_bounds.target).and_return(true)
        end

        it 'returns true' do
          expect(full_in_bounds.in_bounds?(board)).to be true
        end
      end

      context 'when it is not in bounds' do
        subject(:full_out_bounds) { described_class.parse('a1b1') }

        let(:board) { instance_double(Board) }

        before do
          allow(board).to receive(:in_bounds?).with(full_out_bounds.start).and_return(true)
          allow(board).to receive(:in_bounds?).with(full_out_bounds.target).and_return(false)
        end

        it 'returns false' do
          expect(full_out_bounds.in_bounds?(board)).to be false
        end
      end
    end

    context 'when it is a partial move' do
      context 'when it is in bounds' do
        subject(:partial_in_bounds) { described_class.parse('a1') }

        let(:board) { instance_double(Board) }

        before do
          allow(board).to receive(:in_bounds?).with(partial_in_bounds.start).and_return(true)
        end

        it 'returns true' do
          expect(partial_in_bounds.in_bounds?(board)).to be true
        end
      end

      context 'when it is not in bounds' do
        subject(:partial_out_bounds) { described_class.parse('a1') }

        let(:board) { instance_double(Board) }

        before do
          allow(board).to receive(:in_bounds?).with(partial_out_bounds.start).and_return(false)
        end

        it 'returns false' do
          expect(partial_out_bounds.in_bounds?(board)).to be false
        end
      end
    end
  end
end
