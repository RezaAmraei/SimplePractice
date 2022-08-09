FactoryBot.define do
  factory :appointment do
    doctor { create(:doctor) }
    patient { create(:patient) }
    start_time { Time.zone.now }
    duration_in_minutes { 50 }
  end
end
