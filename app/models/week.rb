# frozen_string_literal: true

class Week < ApplicationRecord
  INACTIVE = 'inactive'
  COMING   = 'coming'
  ACTIVE   = 'active'

  belongs_to :season

  has_many :games, dependent: :destroy
  has_many :games_players, through: :games

  has_many :fantasy_leagues, as: :leagueable, dependent: :destroy

  has_many :lineups, dependent: :destroy
  has_many :fantasy_teams, through: :lineups

  enum status: { INACTIVE => 0, COMING => 1, ACTIVE => 2 }

  scope :active, -> { where(status: ACTIVE) }

  delegate :league, to: :season

  def previous
    Week.find_by(season_id: season_id, position: position - 1)
  end

  def next
    Week.find_by(season_id: season_id, position: position + 1)
  end
end
