Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "photos#index"
  resources :photos, only: [:index, :new, :create]
  resources :uploads, only: [:index, :new, :create]
end
