# frozen_string_literal: true

describe FantasyTeamsController, type: :controller do
  describe 'GET#show' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        get :show, params: { id: 'unexisted', locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not existed fantasy team' do
        it 'renders 404 page' do
          get :show, params: { id: 'unexisted', locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for invalid request format' do
        it 'renders 404 page' do
          get :show, params: { id: 'unexisted', locale: 'en', format: :xml }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed not user fantasy team' do
        let!(:fantasy_team) { create :fantasy_team }

        it 'renders 404 page' do
          get :show, params: { id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed user fantasy team' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          create :fantasy_leagues_team, fantasy_team: fantasy_team
        end

        it 'renders show page' do
          get :show, params: { id: fantasy_team.uuid, locale: 'en' }

          expect(response).to render_template :show
        end
      end
    end
  end

  describe 'POST#create' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        post :create, params: { season_id: 'unexisted', locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not existed season' do
        let(:request) { post :create, params: { season_id: 'unexisted', locale: 'en' } }

        it 'does not create fantasy team' do
          expect { request }.not_to change(FantasyTeam, :count)
        end

        it 'and renders 404 page' do
          request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed active season' do
        let!(:season) { create :season, active: true }
        let!(:fantasy_league) { create :fantasy_league, season: season, leagueable: season, name: 'Overall' }
        let(:request) { post :create, params: { season_id: season.id, locale: 'en' } }

        context 'if fantasy team is already exist' do
          let!(:fantasy_team) { create :fantasy_team, user: @current_user }

          before do
            create :fantasy_leagues_team, fantasy_league: fantasy_league, fantasy_team: fantasy_team
          end

          it 'does not create fantasy team' do
            expect { request }.not_to change(FantasyTeam, :count)
          end

          it 'and redirects to home page' do
            request

            expect(response).to redirect_to home_en_path
          end
        end

        context 'if fantasy team is not exist' do
          it 'creates fantasy team' do
            expect { request }.to change(@current_user.fantasy_teams, :count).by(1)
          end

          it 'and redirects to home page' do
            request

            expect(response).to redirect_to fantasy_team_transfers_en_path(FantasyTeam.last.uuid)
          end
        end
      end
    end
  end

  describe 'PATCH#update' do
    context 'for unlogged users' do
      it 'redirects to login path' do
        patch :update, params: { id: 'unexisted', locale: 'en' }

        expect(response).to redirect_to users_login_en_path
      end
    end

    context 'for logged users' do
      sign_in_user

      context 'for not existed fantasy team' do
        let(:request) { patch :update, params: { id: 'unexisted', locale: 'en' } }

        it 'does not update fantasy team' do
          expect { request }.not_to change(FantasyTeam, :count)
        end

        it 'and renders 404 page' do
          request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existed fantasy team' do
        let!(:fantasy_league) { create :fantasy_league }
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          create :fantasy_leagues_team, fantasy_league: fantasy_league, fantasy_team: fantasy_team
        end

        context 'for league at maintenance' do
          before do
            fantasy_league.season.league.update(maintenance: true)

            patch :update, params: {
              id: fantasy_team.uuid, locale: 'en', fantasy_team: { name: 'New name', budget_cents: 50_000 }
            }
          end

          it 'returns status 422' do
            expect(response.status).to eq 422
          end

          it 'and returns error about maintenance' do
            expect(JSON.parse(response.body)).to eq({ 'errors' => ['League is on maintenance'] })
          end
        end

        context 'for standard league' do
          let(:complete_service) { double }

          before do
            allow(FantasyTeams::CompleteService).to receive(:call).and_return(complete_service)
          end

          context 'for invalid data' do
            let(:request) {
              patch :update, params: {
                id: fantasy_team.uuid, locale: 'en', fantasy_team: { name: '', budget_cents: 50_000 }
              }
            }

            before do
              allow(complete_service).to receive(:success?).and_return(false)
              allow(complete_service).to receive(:errors).and_return([])
            end

            it 'calls complete service' do
              request

              expect(FantasyTeams::CompleteService).to have_received(:call)
            end

            it 'and returns json unprocessable_entity status with errors' do
              request

              expect(response.status).to eq 422
            end
          end

          context 'for valid data' do
            let(:request) {
              patch :update, params: {
                id: fantasy_team.uuid, locale: 'en', fantasy_team: { name: 'New name', budget_cents: 50_000 }
              }
            }

            before do
              allow(complete_service).to receive(:success?).and_return(true)
            end

            it 'calls complete service' do
              request

              expect(FantasyTeams::CompleteService).to have_received(:call)
            end

            it 'and returns json ok status' do
              request

              expect(response.status).to eq 200
            end
          end
        end
      end
    end
  end
end
