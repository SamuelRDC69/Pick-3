# frozen_string_literal: true

Rails.application.routes.draw do
  localized do
    namespace :users do
      get 'sign_up', to: 'registrations#new'
      post 'sign_up', to: 'registrations#create'

      get 'login', to: 'sessions#new'
      post 'login', to: 'sessions#create'
      get 'logout', to: 'sessions#destroy'
    end

    namespace :admin do
      resources :leagues, only: %i[show] do
        resources :games, only: %i[show], module: 'leagues'
      end
      resources :games, only: %i[] do
        post 'players', to: 'games/players#update'
      end
    end

    resource :home, only: %i[show]
    resources :fantasy_teams, only: %i[show create update] do
      scope module: :fantasy_teams do
        resource :transfers, only: %i[show update]
        resources :points, only: %i[index]
        resources :players, only: %i[index]
      end
    end
    resources :lineups, only: %i[] do
      resource :players, only: %i[show update], module: 'lineups'
    end
    resources :sports, only: %i[] do
      resources :positions, only: %i[index], module: 'sports'
    end
    resources :teams, only: %i[index]
    resources :seasons, only: %i[] do
      resources :players, only: %i[index], module: 'seasons'
    end
    resources :weeks, only: %i[show]

    root 'welcome#index'
  end
end
