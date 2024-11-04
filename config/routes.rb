# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users,
             controllers: { omniauth_callbacks: "users/omniauth_callbacks" },
             skip: %i[sessions registrations]

  devise_scope :user do
    get "sign_in", to: "devise/sessions#new", as: :new_user_session
    get "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  resources :sheets, only: %i[index show] do
    collection do
      post :fetch
    end
    member do
      get :print
      get :preview
    end
  end

  root "home#index"
end
