class CreateHomeReadings < ActiveRecord::Migration[8.0]
  def change
    create_table :home_readings do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.date    :recorded_on, null: false
      t.integer :systolic_bp
      t.integer :diastolic_bp
      t.integer :pulse
      t.decimal :weight_kg, precision: 5, scale: 2
      t.boolean :meds_taken, default: true, null: false
      t.text    :notes
      t.timestamps
    end
    add_index :home_readings, [ :patient_id, :recorded_on ]
  end
end
