# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_leagues_team, class: 'FantasyLeagues::Team' do
    association :fantasy_league
    association :fantasy_team
  end
end
