# frozen_string_literal: true

module Import
  module Balldontlie
    module Basketball
      class FetchService
        prepend ApplicationService

        def initialize(
          http_service: HttpService::Client.new(url: 'https://www.balldontlie.io')
        )
          @http_service = http_service
          @result = [{}, {}]
        end

        def call(external_id:)
          @external_id = external_id
          @game = Game.find_by(external_id: external_id)

          fetch_data
            .then { |game_data| parse_data(game_data) }
        end

        private

        def fetch_data
          @http_service.get(path: "/api/v1/stats?game_ids[]=#{@external_id}")['data']
        end

        def parse_data(game_data)
          @home_season_team_id = @game.home_season_team_id
          @home_team_name = @game.home_season_team.team.name['en']
          @visitor_season_team_id = @game.visitor_season_team_id
          @visitor_team_name = @game.visitor_season_team.team.name['en']

          game_data.each { |player_data| parse_player_data(player_data) }
        end

        def parse_player_data(player_data)
          team_index = team_index_of_player(player_data)
          shirt_number = shirt_number(player_data, team_index)
          return unless shirt_number

          @result[team_index][shirt_number] = {
            'P'   => player_data['pts'],
            'REB' => player_data['reb'],
            'A'   => player_data['ast'],
            'BLK' => player_data['blk'],
            'STL' => player_data['stl'],
            'TO'  => player_data['turnover']
          }
        end

        def team_index_of_player(player_data)
          case player_data['team']['full_name']
          when @home_team_name then 0
          when @visitor_team_name then 1
          end
        end

        def shirt_number(player_data, team_index)
          full_name = "#{player_data['player']['last_name']} #{player_data['player']['first_name']}"
          Teams::Player
            .joins(:player)
            .where(seasons_team_id: season_team_by_team_index(team_index), active: true)
            .where('players.name @> ?', { en: full_name }.to_json)
            .first
            &.shirt_number
        end

        def season_team_by_team_index(team_index)
          case team_index
          when 0 then @home_season_team_id
          when 1 then @visitor_season_team_id
          end
        end
      end
    end
  end
end
