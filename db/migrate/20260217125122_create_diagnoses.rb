class CreateDiagnoses < ActiveRecord::Migration[8.0]
  def change
    create_table :diagnoses do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :visit, foreign_key: true
      t.references :diagnosed_by, foreign_key: { to_table: :users }
      t.string :icd_code
      t.string :description, null: false
      t.integer :diagnosis_type, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.date :onset_date
      t.date :resolved_date
      t.text :notes
      t.timestamps
    end

    add_index :diagnoses, [:patient_id, :status]
    add_index :diagnoses, :icd_code
  end
end
