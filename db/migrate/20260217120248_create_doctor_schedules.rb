class CreateDoctorSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :doctor_schedules do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :slot_duration_minutes, default: 30
      t.integer :max_patients, default: 20
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :doctor_schedules, [:doctor_id, :day_of_week], unique: true
  end
end
