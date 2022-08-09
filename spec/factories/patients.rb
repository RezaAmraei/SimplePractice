FactoryBot.define do
  factory :patient do
    doctor { create(:doctor) }
    name { "Patient Zero" }
  end
end
