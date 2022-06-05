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
end
