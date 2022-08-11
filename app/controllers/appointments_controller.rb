require 'date'
class AppointmentsController < ApplicationController
  def appointments
    results_for_appointments = ActiveRecord::Base.connection.execute(
      "SELECT appointments.id , doctors.name as doctor , appointments.doctor_id, appointments.patient_id, patients.name as patient, appointments.created_at, appointments.start_time, appointments.duration_in_minutes FROM appointments 
      JOIN doctors ON doctors.id = appointments.doctor_id
      JOIN patients ON patients.id = appointments.patient_id; ")

      
      all_appointments = results_for_appointments.map { |obj|
        { 
          "id" => obj["id"],
          "patient" => {
            "name" => obj["patient"]
            },
          "doctor" => {
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
        length = params[:length].to_i
        page = params[:page].to_i
        
        all_appointments.each_with_index do |appointment, index|
          if index <= ((page * length) - 1) && index >= (((page * length) - length) - 1 )
            range_of_appointments.push(appointment)
          end
        end
        render json:  range_of_appointments
      else

        render json: all_appointments
      end
  end

  def doctors_with_no_appointments
    current_datetime = DateTime.now

    result_for_all_doctors = Doctor.all
    result_for_all_doctors_with_no_appointments = []
    result_for_doctors_with_appointments = ActiveRecord::Base.connection.execute("SELECT DISTINCT name from doctors JOIN appointments ON appointments.doctor_id = doctors.id WHERE appointments.start_time > '#{current_datetime}' ")

    result_for_all_doctors.each do |one_doctor_in_all|
      result_for_doctors_with_appointments.each do |one_doctor_in_all_with_appointments|
        if one_doctor_in_all["name"] == one_doctor_in_all_with_appointments["name"]
          result_for_all_doctors_with_no_appointments.push({"name" => one_doctor_in_all["name"]})
        end
      end
    end

    render json: result_for_all_doctors_with_no_appointments
  end
  

  def create_appointment 
    current_patient = Patient.find_by_name(params[:patient_name])

    if current_patient.blank?
      render json: {"error" => "This patient does not exist, check spelling or make sure patient is registered"}
    else
      #assuming since each patient can only have one doctor I added this validation to make sure the proper doctor_id is inserted
      if current_patient["doctor_id"].to_i == params[:doctor_id]
        appointment = Appointment.new(doctor_id: params[:doctor_id], patient_id: current_patient["id"].to_i, start_time: params[:start_time], duration_in_minutes: params[:duration_in_minutes])

          if appointment.save
            render json: appointment, status: :created
          else
            render json: appointment.errors, status: :unproccessable_entity
        end
      else 
        render json: {"Error" => "Invalid Doctor ID, please insert the correct ID"}
      end
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:doctor_id, :patient_name, :start_time, :duration_in_minutes)
  end
end


