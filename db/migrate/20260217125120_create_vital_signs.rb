class CreateVitalSigns < ActiveRecord::Migration[8.0]
  def change
    create_table :vital_signs do |t|
      t.references :visit, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :recorded_by, null: false, foreign_key: { to_table: :users }
      t.integer :measurement_type, default: 0, null: false
      t.integer :systolic_bp
      t.integer :diastolic_bp
      t.integer :heart_rate
      t.decimal :temperature, precision: 4, scale: 1
      t.decimal :weight_kg, precision: 5, scale: 1
      t.decimal :height_cm, precision: 5, scale: 1
      t.integer :respiratory_rate
      t.integer :oxygen_saturation
      t.decimal :blood_sugar, precision: 5, scale: 1
      t.datetime :recorded_at, null: false
      t.timestamps
    end

    add_index :vital_signs, [:patient_id, :recorded_at]
    add_index :vital_signs, :measurement_type
  end
end
