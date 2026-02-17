class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.integer :amount_cents, null: false
      t.integer :payment_method, null: false, default: 0  # 0=cash, 1=card, 2=paystack, 3=insurance, 4=bank_transfer
      t.integer :status, null: false, default: 0          # 0=pending, 1=successful, 2=failed, 3=refunded
      t.string :paystack_reference
      t.string :paystack_access_code
      t.text :notes

      t.timestamps
    end

    add_index :payments, :paystack_reference, unique: true, where: "paystack_reference IS NOT NULL"
    add_index :payments, :status
    add_index :payments, [ :invoice_id, :status ]
  end
end
