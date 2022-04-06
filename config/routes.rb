Rails.application.routes.draw do
  post '/api_key', to: 'courses#api_key'
  get '/index', to: 'courses#index'
  get '/login', to: 'courses#login'

  root 'courses#login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
