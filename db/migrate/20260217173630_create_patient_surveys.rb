class CreatePatientSurveys < ActiveRecord::Migration[8.0]
  def change
    create_table :patient_surveys do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :visit, null: true, foreign_key: true
      t.integer :overall_rating, null: false
      t.integer :doctor_rating
      t.integer :staff_rating
      t.text :comments
      t.boolean :published, null: false, default: false

      t.timestamps
    end

    add_index :patient_surveys, [ :patient_id, :visit_id ], unique: true,
              name: "idx_surveys_patient_visit"
  end
end
