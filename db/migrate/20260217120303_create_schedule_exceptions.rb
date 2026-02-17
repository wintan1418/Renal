class CreateScheduleExceptions < ActiveRecord::Migration[8.0]
  def change
    create_table :schedule_exceptions do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.date :exception_date, null: false
      t.boolean :available, default: false, null: false
      t.time :start_time
      t.time :end_time
      t.string :reason

      t.timestamps
    end

    add_index :schedule_exceptions, [:doctor_id, :exception_date], unique: true
  end
end
