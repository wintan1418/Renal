class CreateEmergencyContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :emergency_contacts do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :phone, null: false
      t.string :relationship, null: false
      t.boolean :is_primary, null: false, default: false

      t.timestamps
    end

  end
end
