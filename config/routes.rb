Rails.application.routes.draw do
  resource :q, controller: "q", only: [] do
    get :start
    get :complete
    get :failure
    get :retry
    get :giveup
    get :ranking
    post :update
  end
  resources :rankings
  resource :ranking, only: [] do
    post :log
  end

  resources :questions
  resource :stopwatch, only: [ :show ] do
    post :start
    post :stop
    post :reset
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "q#start"
end
