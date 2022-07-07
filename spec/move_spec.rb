# frozen_string_literal: true

require_relative '../lib/move'

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
        expect(two_parse.parse(single_coordinate)).to have_attributes(start: 'a1')
      end
    end

    context 'when it is given given a string with length of four' do
      subject(:four_parse) { described_class }

      let(:double_coordinate) { 'h8d4' }

      it 'creates new Move with @start and @target' do
        expect(four_parse.parse(double_coordinate)).to have_attributes(start: 'h8', target: 'd4')
      end
    end

    context 'when it is given too short or too long of a string' do
      subject(:nil_parse) { described_class }

      let(:long_coordinate) { 'a11b99'}

      it 'returns nil' do
        expect(nil_parse.parse(long_coordinate)).to be_nil
      end
    end
  end
end
