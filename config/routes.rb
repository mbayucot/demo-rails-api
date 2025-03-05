Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :stores do
    resources :products do
      member do
        post :submit_for_review
        post :approve
        post :reject
        post :discard
        post :restore
      end
    end
  end
end
