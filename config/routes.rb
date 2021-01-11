Rails.application.routes.draw do
  # Devise
  devise_for :users, controllers: {registrations: 'users/registrations'}

  # Generale Routes
  root to: 'pages#home'

  # Players
  get '/stats', to:'players#stats'

  # Games
  resources :games, except: [:show] do
    post '/validate',  to:'games#validate'
  end

  # API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :players, only: [ :index, :show ]
      resources :tournaments, only: [ :index ]
      resources :games, only: [ :index ] 
    end
  end

end
