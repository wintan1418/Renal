class CreateLabResults < ActiveRecord::Migration[8.0]
  def change
    create_table :lab_results do |t|
      t.references :lab_order, null: false, foreign_key: true
      t.references :lab_test, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.string :value
      t.decimal :numeric_value, precision: 10, scale: 2
      t.integer :flag, default: 0, null: false
      t.date :result_date
      t.references :resulted_by, foreign_key: { to_table: :users }
      t.text :notes
      t.timestamps
    end

    add_index :lab_results, [:patient_id, :lab_test_id, :result_date], name: "idx_lab_results_patient_test_date"
    add_index :lab_results, :flag
  end
end
