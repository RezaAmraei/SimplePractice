class AddAppointmentStartTime < ActiveRecord::Migration[6.0]
  def change
    change_table :appointments do |t|
      t.datetime :start_time, null: false
      t.integer :duration_in_minutes, default: 0.0
    end
  end
end
