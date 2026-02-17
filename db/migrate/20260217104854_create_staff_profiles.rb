class CreateStaffProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :department, foreign_key: true
      t.string :employee_id
      t.string :specialization
      t.string :license_number
      t.string :qualification
      t.text :bio
      t.integer :consultation_fee_cents, default: 0
      t.boolean :available_for_telemedicine, default: false
      t.integer :years_of_experience

      t.timestamps
    end

    add_index :staff_profiles, :employee_id, unique: true
  end
end
