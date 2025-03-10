require "sidekiq/web"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount Sidekiq::Web => "/sidekiq"

  # Defines the root path route ("/")
  # root "articles#index"
  resources :stores do
    resources :products
  end

  resources :file_imports, only: [:index, :create]

  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             },
             defaults: { format: :json }
end
