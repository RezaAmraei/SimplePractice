# TODO: Seed the database according to the following requirements:
# - There should be 10 Doctors with unique names
# - Each doctor should have 10 patients with unique names
# - Each patient should have 10 appointments (5 in the past, 5 in the future)
#   - Each appointment should be 50 minutes in duration
require 'faker'
Doctor.destroy_all
Patient.destroy_all
Appointment.destroy_all

for i in 1..10
    doctor = Doctor.create!(
        {
            name: Faker::Name.unique.first_name
        }
    )

    for j in 1..10
        patient = Patient.create!(
            {
                doctor_id: doctor.id,
                name: Faker::Name.unique.first_name
            }
        )
        
        for k in 1..10
            if k <= 5
                Appointment.create!(
                    {
                        doctor_id: doctor.id,
                        patient_id: patient.id,
                        start_time: Faker::Time.forward,
                        duration_in_minutes: 50
                    }
                )
            else
                Appointment.create!(
                    {
                        doctor_id: doctor.id,
                        patient_id: patient.id,
                        start_time: Faker::Time.backward,
                        duration_in_minutes: 50
                    }
                )
            end
        end
    end
end

p "Created #{Doctor.count} doctors"
p "Created #{Patient.count} patients"
p "Created #{Appointment.count} appointments"
