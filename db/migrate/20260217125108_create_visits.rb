class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :appointment, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.date :visit_date, null: false
      t.integer :visit_type, default: 0, null: false
      t.text :chief_complaint
      t.integer :status, default: 0, null: false
      t.timestamps
    end

    add_index :visits, [:patient_id, :visit_date]
    add_index :visits, :status
  end
end
