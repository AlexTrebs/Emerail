Rails.application.routes.draw do
  devise_for :users

  resources :email_accounts, only: [ :index, :new, :create, :destroy ] do
    member do
      post :sync
    end
  end

  resources :email_messages, only: [ :index, :show ] do
    member do
      patch :mark_read
      patch :mark_unread
    end
  end

  root "email_messages#index"
end
