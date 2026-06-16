class AddCrmToContactSubmissions < ActiveRecord::Migration[8.0]
  def change
    change_table :contact_submissions, bulk: true do |t|
      t.integer  :stage, default: 0, null: false        # new_lead, contacted, qualified, booked, converted, lost
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.date     :follow_up_on
      t.datetime :last_contacted_at
      t.string   :source, default: "website"
      t.integer  :estimated_value_cents
    end
    add_index :contact_submissions, :stage
    add_index :contact_submissions, :follow_up_on

    create_table :lead_activities do |t|
      t.references :contact_submission, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :kind, default: 0, null: false           # note, call, email, whatsapp, stage_change, meeting
      t.text :body
      t.timestamps
    end
  end
end
