class CreateRecurringSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :recurring_schedules do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.references :service, null: false, foreign_key: true
      t.integer :days_of_week, array: true, default: []
      t.time :start_time, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :recurring_schedules, :days_of_week, using: :gin
  end
end
