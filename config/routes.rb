Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      get 'merchants/find', to: 'merchants#find'
      get 'merchants/find_all', to: 'merchants#find_all'
      get 'merchants/find_all', to: 'merchants#most_items'
      resources :merchants, only: %i[index show] do
        resources :items, controller: 'merchant_items', only: [:index]
      end
      get 'items/find', to: 'items#find'
      get 'items/find_all', to: 'items#find_all'
      resources :items, only: %i[index show create update destroy] do
        resources :merchant, controller: 'merchant_items', only: [:index]
      end
      namespace :revenue do 
        resources :merchants, only: [:index, :show]
        resources :items, only: [:index]
      end
    end
  end
end
