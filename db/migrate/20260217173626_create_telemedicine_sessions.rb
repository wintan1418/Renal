class CreateTelemedicineSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :telemedicine_sessions do |t|
      t.references :appointment, null: true, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.string :room_id, null: false
      t.integer :status, null: false, default: 0  # 0=scheduled, 1=active, 2=completed, 3=cancelled
      t.datetime :started_at
      t.datetime :ended_at
      t.text :notes

      t.timestamps
    end

    add_index :telemedicine_sessions, :room_id, unique: true
    add_index :telemedicine_sessions, :status
    add_index :telemedicine_sessions, [ :patient_id, :created_at ]
  end
end
