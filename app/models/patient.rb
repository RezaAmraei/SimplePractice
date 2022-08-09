# For this test app, you can assume a patient has only one doctor
class Patient < ApplicationRecord
  belongs_to :doctor
  has_many :appointments
end
