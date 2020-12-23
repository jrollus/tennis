Rails.application.routes.draw do
  # Devise
  devise_for :users, controllers: {registrations: 'users/registrations'}

  # Generale Routes
  root to: 'pages#home'
  resources :games, except: [:show]

  # API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :players, only: [ :index, :show ]
      resources :tournaments, only: [ :index ]
    end
  end

end
