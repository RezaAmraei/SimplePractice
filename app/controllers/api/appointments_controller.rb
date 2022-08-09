class Api::AppointmentsController < ApplicationController
  def index
  end
  
  def appointments
    @appointments = Appointment.all
    render json: @appointments
  end

  def test
  end
  
end
