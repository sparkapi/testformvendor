Rails.application.routes.draw do
  root 'main#index'
  get 'main/index'

  get 'callback' => 'main#callback'
  get 'properties' => 'main#properties'
  post 'properties' => 'main#properties'

  get 'diagram' => 'main#diagram'
  post 'diagram' => 'main#diagram'

  # Used by Github.com to trigger a new deployment
  post 'webhook' => 'deploy#webhook'

  # auth system for RESO members
  get 'login' => "user#login"
  post 'login' => "user#authenticate"
  get 'logout' => "user#logout"

  # Providers resource for members
  resources :providers
  get 'public_providers' => "providers#public_index"
end
