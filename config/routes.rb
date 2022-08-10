Rails.application.routes.draw do
    get 'api/appointments', :to => "appointments#appointments"
    get 'api/doctors', :to => "appointments#doctors_with_no_appointments"
    post 'api/appointments', :to  => "appointments#create_appointment"
end
