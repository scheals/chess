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

  describe '#==' do
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

  describe '#same_column?' do
    subject(:starting_coordinate) { described_class.new('f6') }

    context 'when column is the same' do
      let(:climbing_coordinate) { described_class.new('f7') }

      it 'returns true' do
        expect(starting_coordinate.same_column?(climbing_coordinate)).to be true
      end
    end

    context 'when column is not the same' do
      let(:sliding_coordinate) { described_class.new('e7') }

      it 'returns false' do
        expect(starting_coordinate.same_column?(sliding_coordinate)).to be false
      end
    end
  end

  describe '#same_row?' do
    subject(:starting_coordinate) { described_class.new('a4') }

    context 'when row is the same' do
      let(:sliding_coordinate) { described_class.new('b4') }

      it 'returns true' do
        expect(starting_coordinate.same_row?(sliding_coordinate)).to be true
      end
    end

    context 'when row is not the same' do
      let(:climbing_coordinate) { described_class.new('a5') }

      it 'returns false' do
        expect(starting_coordinate.same_row?(climbing_coordinate)).to be false
      end
    end
  end

  describe '#up' do
    subject(:starting_coordinate) { described_class.new('d4') }

    let(:one_up) { described_class.new('d5') }

    it 'returns coordinate one row up' do
      expect(starting_coordinate.up).to eq(one_up)
    end
  end

  describe '#down' do
    subject(:starting_coordinate) { described_class.new('c8') }

    let(:one_down) { described_class.new('c7') }

    it 'returns coordinate one row down' do
      expect(starting_coordinate.down).to eq(one_down)
    end
  end

  describe '#left' do
    subject(:starting_coordinate) { described_class.new('b4') }

    let(:one_left) { described_class.new('a4') }

    it 'returns coordinate one column left' do
      expect(starting_coordinate.left).to eq(one_left)
    end
  end

  describe '#right' do
    subject(:starting_coordinate) { described_class.new('e3') }

    let(:one_right) { described_class.new('f3') }

    it 'returns coordinate one column right' do
      expect(starting_coordinate.right).to eq(one_right)
    end
  end

  describe '#to_left?' do
    subject(:position) { described_class.new('l8') }

    it 'returns true for coordinate to the left of itself' do
      to_the_left = 'k8'
      expect(position.to_left?(to_the_left)).to be true
    end

    it 'returns false for coordinate to the right of itself' do
      to_the_right = 'm5'
      expect(position.to_left?(to_the_right)).to be false
    end

    it 'returns false if the column is the same' do
      upwards = 'l10'
      expect(position.to_left?(upwards)).to be false
    end
  end

  describe '#to_right?' do
    subject(:position) { described_class.new('d8') }

    it 'returns false for coordinate to the left of itself' do
      to_the_left = 'a1'
      expect(position.to_right?(to_the_left)).to be false
    end

    it 'returns true for coordinate to the right of itself' do
      to_the_right = 'm5'
      expect(position.to_right?(to_the_right)).to be true
    end

    it 'returns false if the column is the same' do
      upwards = 'd900'
      expect(position.to_right?(upwards)).to be false
    end
  end

  describe '#to_up?' do
    subject(:position) { described_class.new('n3') }

    it 'returns true for coordinate to upwards from itself' do
      upwards = 'a7'
      expect(position.to_up?(upwards)).to be true
    end

    it 'returns false for coordinate to downwards from itself' do
      downwards = 'm1'
      expect(position.to_up?(downwards)).to be false
    end

    it 'returns false if the row is the same' do
      leftwards = 'g3'
      expect(position.to_up?(leftwards)).to be false
    end
  end

  describe '#to_down?' do
    subject(:position) { described_class.new('f8') }

    it 'returns false for coordinate to upwards from itself' do
      upwards = 'a9'
      expect(position.to_down?(upwards)).to be false
    end

    it 'returns true for coordinate to downwards from itself' do
      downwards = 'm1'
      expect(position.to_down?(downwards)).to be true
    end

    it 'returns false if the row is the same' do
      rightwards = 'g8'
      expect(position.to_down?(rightwards)).to be false
    end
  end
end
