# frozen_string_literal: true

describe Week, type: :model do
  it 'factory should be valid' do
    week = build :week

    expect(week).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:season) }
    it { is_expected.to have_many(:games).dependent(:destroy) }
    it { is_expected.to have_many(:fantasy_leagues).dependent(:destroy) }
  end
end
