class CreateInsuranceClaims < ActiveRecord::Migration[8.0]
  def change
    create_table :insurance_claims do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.string :provider_name, null: false
      t.string :policy_number
      t.string :member_id
      t.integer :claim_amount_cents, null: false, default: 0
      t.integer :approved_amount_cents, default: 0
      t.integer :status, null: false, default: 0  # 0=submitted, 1=under_review, 2=approved, 3=rejected, 4=paid
      t.date :submitted_at
      t.date :responded_at
      t.text :notes

      t.timestamps
    end

    add_index :insurance_claims, :status
  end
end
