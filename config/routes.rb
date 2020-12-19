Rails.application.routes.draw do
  # Devise
  devise_for :users, controllers: {registrations: 'users/registrations'}

  # General routes
  root to: 'pages#home'

  # API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :players, only: [ :show ]
    end
  end

end
