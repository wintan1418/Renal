class CreateClinicalNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :clinical_notes do |t|
      t.references :visit, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.integer :note_type, default: 0, null: false
      t.text :subjective
      t.text :objective
      t.text :assessment
      t.text :plan
      t.text :body
      t.timestamps
    end

    add_index :clinical_notes, :note_type
  end
end
