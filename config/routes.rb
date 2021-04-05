Rails.application.routes.draw do
  get 'validations/index'
  # Devise
  devise_for :users, controllers: {registrations: 'users/registrations'}

  # Generale Routes
  root to: 'pages#home'

  # Ranking Histories
  resources :ranking_histories, only: [:index, :edit, :update], path: 'ranking-histories' do
    post '/validate',  to:'ranking_histories#validate'
  end

  # Players
  resources :players, only: [:new, :create, :edit, :update] do
    post '/validate', to:'players#validate'
  end

  get '/players', to:'players#index', constraints: lambda { |req| req.format == :json }
  get '/players/:id', to:'players#show', constraints: lambda { |req| req.format == :json }
  get '/players-validations', to:'players#validations'
  get '/stats', to:'players#stats'
  get '/compare', to:'players#compare'

  # Tournaments
  resources :tournaments, only: [:new, :create, :edit, :update] do
    post '/validate', to:'tournaments#validate'
  end

  get '/tournaments', to:'tournaments#index', constraints: lambda { |req| req.format == :json }
  get '/tournaments-validations', to:'tournaments#validations'

  # Games
  resources :games, except: [:show] do
    post '/validate',  to:'games#validate'
  end

end
