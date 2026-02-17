class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.references :service, null: false, foreign_key: true
      t.references :department, foreign_key: true
      t.references :recurring_schedule, foreign_key: true
      t.date :scheduled_date, null: false
      t.time :start_time, null: false
      t.time :end_time
      t.integer :status, default: 0, null: false
      t.integer :appointment_type, default: 0, null: false
      t.text :reason
      t.integer :queue_number
      t.text :notes
      t.references :checked_in_by, foreign_key: { to_table: :users }
      t.datetime :checked_in_at

      t.timestamps
    end

    add_index :appointments, [:doctor_id, :scheduled_date, :start_time], name: "idx_appointments_doctor_date_time"
    add_index :appointments, [:patient_id, :scheduled_date]
    add_index :appointments, :status
    add_index :appointments, :scheduled_date
  end
end
