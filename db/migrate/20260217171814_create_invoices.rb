class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :visit, null: true, foreign_key: true
      t.string :invoice_number, null: false
      t.integer :status, null: false, default: 0  # 0=draft, 1=sent, 2=paid, 3=overdue, 4=cancelled
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :discount_cents, null: false, default: 0
      t.integer :tax_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.integer :amount_paid_cents, null: false, default: 0
      t.date :due_date
      t.text :notes

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status
    add_index :invoices, [ :patient_id, :status ]
  end
end
