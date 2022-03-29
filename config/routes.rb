Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/api/vi/items/find', to: 'items#find'
  get '/api/vi/items/find_all', to: 'items#find_all'
  
  get '/api/vi/merchants/find', to: 'merchants#find'
  get '/api/vi/merchants/find_all', to: 'merchants#find_all'

  namespace :api do 
    namespace :v1 do 
      resources :merchants, only: [:index, :show] do 
        resources :items, controller: 'merchant_items', only: [:index]
      end
      resources :items, only: [:index, :show, :create, :update, :destroy] do 
        resources :merchant, controller: 'merchant_items', only: [:index]
      end
    end
  end
end
