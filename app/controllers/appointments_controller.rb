
class AppointmentsController < ApplicationController
  def appointments
    results_for_appointments = ActiveRecord::Base.connection.execute(
      "SELECT appointments.id , doctors.name as doctor , appointments.doctor_id, appointments.patient_id, patients.name as patient, appointments.created_at, appointments.start_time, appointments.duration_in_minutes FROM appointments 
      JOIN doctors ON doctors.id = appointments.doctor_id
      JOIN patients ON patients.id = appointments.patient_id; ")

      
      all_appointments = results_for_appointments.map { |obj|
        { 
          "id" => obj["id"],
          "patient" => 
          {
            "name" => obj["patient"]
          },
          "doctor" => 
          {
            "name" => obj["doctor"],
            "id" => obj["doctor_id"]
          },
          "created_at" => obj["created_at"],
          "start_time" => obj["start_time"],
          "duration_in_minutes" => obj["duration_in_minutes"]
        } 
      }

      if params[:past] == '1'
        past_appointments = all_appointments.select { |appointment| 
          appointment["start_time"].to_f < DateTime.now.to_f
        }
        render json: past_appointments
      elsif params[:past] == '0'
        future_appointments = all_appointments.select { |appointment| 
          appointment["start_time"].to_f > DateTime.now.to_f
        }
        render json: future_appointments
      elsif params[:length] && params[:page]
        range_of_appointments = []
        #created these variables just to make the if condition more readable
        length = params[:length].to_i
        page = params[:page].to_i
        
        all_appointments.each_with_index do |appointment,index|
          if index <= ((page * length) - 1) && index >= (((page * length) - length) - 1 )
            range_of_appointments.push(appointment)
          end
        end
        render json: {
          "page" => page,
          "length" => length,
          "appointments" => range_of_appointments
        }
      else
        render json: all_appointments
      end
  end

  def doctors
    results_for_doctor_appointments = ActiveRecord::Base.connection.execute(
      "SELECT appointments.id , doctors.name as doctor , appointments.doctor_id,  appointments.start_time, appointments.duration_in_minutes FROM appointments 
      JOIN doctors ON doctors.id = appointments.doctor_id; ")

    doctors_names = ActiveRecord::Base.connection.execute("SELECT name from doctors")
    
    hash_of_array_of_appointments = {}
    hash_of_doctors_with_no_appointments = {}

    #initalizes data in hash, hash_of_array_of_appointments, with doctors name as key and empty array as the value
    doctors_names.map {|doctor| hash_of_array_of_appointments.merge!("#{doctor["name"]}"=> [])}

    #adds to the array of the doctor if they have an appointment in the future
    results_for_doctor_appointments.each { |appointment| 
      if appointment["start_time"].to_f > DateTime.now.to_f
        hash_of_array_of_appointments[appointment["doctor"]].push(appointment["start_time"])
      end
    }

    #loops through hash to find doctors with no appointments
    hash_of_array_of_appointments.each do |doctor, appointments|
      if appointments.length == 0
        hash_of_doctors_with_no_appointments.merge!(doctor.to_s => "No appointments!")
      end
    end
      render json: hash_of_doctors_with_no_appointments

  end
  
  def create 
    patients = Patient.all

    finder = patients.select { |patient|  patient["name"] == params[:patient_name]}

    appointment = Appointment.new(doctor_id: params[:doctor_id], patient_id: finder[0]["id"], start_time: params[:start_time], duration_in_minutes: params[:duration_in_minutes])
    
    if appointment.save
      render json: appointment, status: :created
    else
      render json: appointment.errors, status: :unproccessable_entity
    end
  end


  private

  def appointment_params
    params.require(:appointment).permit(:doctor_id, :patient_name, :start_time, :duration_in_minutes)
  end
end


