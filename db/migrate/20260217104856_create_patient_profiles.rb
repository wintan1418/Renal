class CreatePatientProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :patient_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :medical_record_number, null: false
      t.date :date_of_birth
      t.integer :gender
      t.integer :blood_group
      t.integer :genotype
      t.integer :marital_status
      t.text :address
      t.string :city
      t.string :state
      t.string :lga
      t.string :occupation
      t.string :religion
      t.string :nationality, default: "Nigerian"
      t.string :nok_name
      t.string :nok_phone
      t.string :nok_relationship
      t.text :nok_address
      t.string :insurance_provider
      t.string :insurance_policy_number
      t.date :insurance_expiry_date
      t.integer :ckd_stage
      t.boolean :on_dialysis, default: false
      t.date :dialysis_start_date
      t.integer :transplant_status, default: 0

      t.timestamps
    end

    add_index :patient_profiles, :medical_record_number, unique: true
    add_index :patient_profiles, :ckd_stage
    add_index :patient_profiles, :on_dialysis
  end
end
