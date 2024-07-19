Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
  
  get "up" => "rails/health#show", as: :rails_health_check

  root "costs#index"

  post 'authenticate', to: 'authentication#authenticate'

  get 'costs/undiscounted/:service', to: 'costs#undiscounted'
  get 'costs/discounted/:service', to: 'costs#discounted'
  get 'costs/blended_rate', to: 'costs#blended_rate'
end
