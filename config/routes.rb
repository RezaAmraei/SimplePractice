Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    get 'api/appointments', :to => "appointments#appointments"
    # get 'api/appointments/:filter', :to => "appointments#appointments"
    get 'api/doctors', :to => "appointments#doctors"
    post 'api/appointments', :to  => "appointments#create"
end
