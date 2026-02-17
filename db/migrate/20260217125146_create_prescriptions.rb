class CreatePrescriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :prescriptions do |t|
      t.references :visit, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :prescribed_by, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.text :notes
      t.timestamps
    end

    add_index :prescriptions, [:patient_id, :created_at]
    add_index :prescriptions, :status
  end
end
