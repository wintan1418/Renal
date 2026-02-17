class CreateTransplantWaitlistEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :transplant_waitlist_entries do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.date :listed_date, null: false
      t.string :blood_group, null: false
      t.integer :status, null: false, default: 0  # 0=active, 1=on_hold, 2=transplanted, 3=removed
      t.integer :priority, null: false, default: 0  # 0=standard, 1=urgent, 2=super_urgent
      t.integer :pra_level  # Panel Reactive Antibody level (0-100%)
      t.text :notes
      t.date :transplant_date

      t.timestamps
    end

    add_index :transplant_waitlist_entries, :status
    add_index :transplant_waitlist_entries, [ :status, :priority, :listed_date ],
              name: "idx_waitlist_priority"
  end
end
