Rails.application.routes.draw do
  resources :home
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    get 'api/appointments', :to => "appointments#appointments"
    get 'api/appointments/:filter', :to => "appointments#appointments"
    get 'api/doctors', :to => "appointments#doctors"
    get 'api/create/:patient/:duration_in_minutes', :to => "appointments#create"
end
