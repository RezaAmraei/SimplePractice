require 'date'
class AppointmentsController < ApplicationController
  def appointments
    results_for_appointments = Appointment.select("appointments.id" , "doctors.name as doctor" , "appointments.doctor_id", "appointments.patient_id", "patients.name as patient", "appointments.created_at", "appointments.start_time", "appointments.duration_in_minutes").joins("JOIN doctors ON doctors.id = appointments.doctor_id").joins("JOIN patients ON patients.id = appointments.patient_id")

    if results_for_appointments.blank?
      render json: {"Message" => "There are no appointments currently in the database"}
    else
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
  end

  def doctors_with_no_appointments
    #I made this function the find all doctors with NO FUTURE appointments
    current_datetime = DateTime.now

    result_for_doctors_id_with_appointments = Doctor.select(:id).joins("JOIN appointments ON appointments.doctor_id = doctors.id WHERE appointments.start_time > '#{current_datetime}'").distinct
    if result_for_doctors_id_with_appointments.blank?
      render json: Doctor.all
    else
      doctors_id_hash_into_array = result_for_doctors_id_with_appointments.map { |doctor_hash| doctor_hash["id"]}
      result_for_all_doctors_with_no_appointments = Doctor.where.not(id: doctors_id_hash_into_array)

      render json: result_for_all_doctors_with_no_appointments
    end
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

