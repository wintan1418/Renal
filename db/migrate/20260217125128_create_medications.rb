class CreateMedications < ActiveRecord::Migration[8.0]
  def change
    create_table :medications do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :dosage
      t.string :frequency
      t.string :route
      t.date :start_date
      t.date :end_date
      t.boolean :active, default: true, null: false
      t.references :prescribed_by, foreign_key: { to_table: :users }
      t.text :notes
      t.timestamps
    end

    add_index :medications, [:patient_id, :active]
  end
end
