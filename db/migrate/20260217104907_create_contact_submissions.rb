class CreateContactSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_submissions do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :subject
      t.text :message, null: false
      t.integer :status, default: 0
      t.references :responded_by, foreign_key: { to_table: :users }
      t.text :response_notes

      t.timestamps
    end
  end
end
