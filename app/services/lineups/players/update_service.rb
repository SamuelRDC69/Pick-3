# frozen_string_literal: true

module Lineups
  module Players
    class UpdateService
      prepend ApplicationService

      def initialize(
        players_validator_service: Lineups::PlayersValidator
      )
        @players_validator_service = players_validator_service
      end

      def call(lineup:, lineups_players_params:)
        @lineup = lineup

        validate_params(lineups_players_params)
        return if failure?

        update_lineups_players(lineups_players_params)
      end

      private

      def validate_params(lineups_players_params)
        fails!(players_validator.call(lineup: @lineup, lineups_players_params: lineups_players_params))
      end

      def players_validator
        @players_validator_service.new(sport_kind: @lineup.fantasy_team.sport_kind)
      end

      def update_lineups_players(lineups_players_params)
        grouped_params = lineups_players_params.index_by { |players_param| players_param.symbolize_keys[:id] }
        @lineup.lineups_players.includes(:lineup, :teams_player).each do |lineups_player|
          lineups_player.update(grouped_params[lineups_player.id].except(:id))
        end
      end
    end
  end
end
