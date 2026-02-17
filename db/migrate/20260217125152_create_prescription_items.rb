class CreatePrescriptionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :prescription_items do |t|
      t.references :prescription, null: false, foreign_key: true
      t.string :medication_name, null: false
      t.string :dosage, null: false
      t.string :frequency, null: false
      t.string :duration
      t.string :route, default: "oral"
      t.integer :quantity
      t.text :instructions
      t.timestamps
    end
  end
end
