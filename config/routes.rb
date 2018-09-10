Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  resources :rosters, only: [:create]
end
