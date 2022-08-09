Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    #resources :appointments, only: [:index]
    get 'test', :to => "appointments#test"
    get 'appointments', :to => "appointments#appointments"
  end
  root to: "main#index"

  

end
