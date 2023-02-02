Rails.application.routes.draw do
  resources :products

  devise_for :users, controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
             }, path: '/', 
             path_names: { 
               sign_in: 'login', 
               sign_out: 'logout',
               password: 'secret',
               confirmation: 'verification',
               unlock: 'unblock', 
               registration: 'user',
               sign_up: '' 
             }


  devise_scope :user do
    match '/user/:id', to: 'users#show', via: :get
    match '/users', to: 'users#show_all', via: :get
    match '/users', to: 'users#update', via: :put
    match '/deposit', to: 'users#deposit', via: :post
    match '/reset', to: 'users#reset', via: :get
    match '/buy', to: 'users#buy', via: :post
    match '/user', to: 'users#create', via: :post
    match '/user', to: 'users#destroy', via: :delete
  end

end
