Rails.application.routes.draw do
  # Devise
  devise_for :users, controllers: {registrations: 'users/registrations'}

  # Generale Routes
  root to: 'pages#home'

  # Ranking Histories
  resources :ranking_histories, only: [:index, :edit, :update] do
    post '/validate',  to:'ranking_histories#validate'
  end

  # Players
  resources :players, only: [:new, :create, :edit, :update]
  get '/stats', to:'players#stats'

  # Tournaments
  resources :tournaments, only: [:new, :create, :edit, :update]
  get '/tournaments', to:'tournaments#index', constraints: lambda { |req| req.format == :json }

  # Games
  resources :games, except: [:show] do
    post '/validate',  to:'games#validate'
  end

  # API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :players, only: [ :index, :show ]
      get '/stats', to:'players#stats'
      resources :games, only: [ :index ] 
    end
  end

end
