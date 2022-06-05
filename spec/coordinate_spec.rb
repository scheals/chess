# frozen_string_literal: true

require_relative '../lib/coordinate'

describe Coordinate do
  describe '@parse' do
    subject(:coordinate) { described_class }

    context 'when it already is a Coordinate' do
      let(:ready_coordinate) { described_class.new('h8') }

      it 'returns itself' do
        expect(coordinate.parse(ready_coordinate)).to be(ready_coordinate)
      end
    end

    context 'when it is not a Coordinate' do
      let(:string_coordinate) { 'a7' }

      it 'returns proper Coordinate' do
        expect(coordinate.parse(string_coordinate)).to be_a(coordinate).and have_attributes(column: 'a', row: '7')
      end
    end
  end

  describe '==' do
    subject(:absolute_coordinate) { described_class.new('00') }

    context 'when row and column are the same' do
      let(:twin_coordinate) { described_class.new('00') }

      it 'returns true' do
        expect(absolute_coordinate == twin_coordinate).to be true
      end
    end

    context 'when either row or column are not the same' do
      let(:different_coordinate) { described_class.new('a0') }

      it 'returns false' do
        expect(absolute_coordinate == different_coordinate).to be false
      end
    end
  end
end
