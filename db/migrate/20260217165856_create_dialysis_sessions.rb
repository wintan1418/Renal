class CreateDialysisSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :dialysis_sessions do |t|
      t.references :appointment, null: true, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.references :nurse, null: true, foreign_key: { to_table: :users }
      t.references :dialysis_machine, null: true, foreign_key: true
      t.references :dialysis_station, null: true, foreign_key: true

      t.integer :session_type, null: false, default: 0   # 0=hemodialysis, 1=peritoneal, 2=hemofiltration
      t.integer :status, null: false, default: 0         # 0=scheduled, 1=in_progress, 2=completed, 3=cancelled, 4=aborted

      t.date :session_date, null: false
      t.time :start_time
      t.time :end_time
      t.integer :duration_minutes

      # Access info
      t.integer :access_type, default: 0                 # 0=fistula, 1=graft, 2=catheter

      # Weights
      t.decimal :pre_weight_kg, precision: 5, scale: 2
      t.decimal :post_weight_kg, precision: 5, scale: 2
      t.decimal :dry_weight_kg, precision: 5, scale: 2
      t.decimal :fluid_removed_ml, precision: 8, scale: 2
      t.decimal :target_fluid_removal_ml, precision: 8, scale: 2

      # Dialysis parameters
      t.decimal :blood_flow_rate, precision: 6, scale: 2       # ml/min
      t.decimal :dialysate_flow_rate, precision: 6, scale: 2   # ml/min
      t.string :dialysate_composition
      t.decimal :heparin_dose_units, precision: 8, scale: 2

      # Pre-dialysis vitals
      t.integer :pre_systolic_bp
      t.integer :pre_diastolic_bp
      t.integer :pre_heart_rate
      t.decimal :pre_temperature, precision: 4, scale: 1

      # Post-dialysis vitals
      t.integer :post_systolic_bp
      t.integer :post_diastolic_bp
      t.integer :post_heart_rate
      t.decimal :post_temperature, precision: 4, scale: 1

      # Outcomes
      t.text :complications
      t.text :nursing_notes
      t.boolean :patient_tolerated_well, default: true

      t.timestamps
    end

    add_index :dialysis_sessions, :session_date
    add_index :dialysis_sessions, :status
    add_index :dialysis_sessions, [ :patient_id, :session_date ]
  end
end
