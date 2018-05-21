Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :clusters, only: [:index, :new, :update, :create, :edit, :destroy]

  resources :servers, only: [:index, :new, :update, :create, :edit, :destroy]

  resources :routings, only: [:index, :new, :update, :create, :edit, :destroy]

  resources :apis
end
