Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :clusters, only: [:index, :new, :update, :create, :edit, :destroy] do
    member do
      get :servers
      delete :unbind
      get :bind_server
      put :bind_server
    end
  end

  resources :servers, only: [:index, :new, :update, :create, :edit, :destroy] do
    member do
      delete :unbind
    end
  end

  resources :routings, only: [:index, :new, :update, :create, :edit, :destroy]

  resources :apis

  root 'home#index'
  resources :home, only: [:index]
end
