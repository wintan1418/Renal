class CreateLabOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :lab_orders do |t|
      t.references :visit, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :ordered_by, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 0, null: false
      t.text :clinical_notes
      t.datetime :collected_at
      t.datetime :completed_at
      t.timestamps
    end

    add_index :lab_orders, :status
    add_index :lab_orders, [:patient_id, :created_at]
  end
end
