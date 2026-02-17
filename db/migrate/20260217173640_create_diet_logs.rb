class CreateDietLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :diet_logs do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.date :log_date, null: false
      t.integer :meal_type, null: false, default: 0  # 0=breakfast, 1=lunch, 2=dinner, 3=snack, 4=total
      t.integer :fluid_intake_ml
      t.decimal :sodium_mg, precision: 8, scale: 2
      t.decimal :potassium_mg, precision: 8, scale: 2
      t.decimal :phosphorus_mg, precision: 8, scale: 2
      t.decimal :protein_g, precision: 8, scale: 2
      t.decimal :calories_kcal, precision: 8, scale: 2
      t.text :notes

      t.timestamps
    end

    add_index :diet_logs, [ :patient_id, :log_date ]
    add_index :diet_logs, [ :patient_id, :log_date, :meal_type ], unique: true,
              name: "idx_diet_logs_patient_date_meal"
  end
end
