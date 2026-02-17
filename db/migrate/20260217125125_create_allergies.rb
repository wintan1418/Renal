class CreateAllergies < ActiveRecord::Migration[8.0]
  def change
    create_table :allergies do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.string :allergen, null: false
      t.string :reaction
      t.integer :severity, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.text :notes
      t.timestamps
    end

    add_index :allergies, [:patient_id, :active]
  end
end
