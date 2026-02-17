class CreateDialysisConsumableUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :dialysis_consumable_usages do |t|
      t.references :dialysis_session, null: false, foreign_key: true
      t.references :dialysis_consumable, null: false, foreign_key: true
      t.decimal :quantity_used, precision: 10, scale: 2, null: false
      t.text :notes

      t.timestamps
    end

    add_index :dialysis_consumable_usages, [ :dialysis_session_id, :dialysis_consumable_id ],
              name: "idx_consumable_usages_session_consumable"
  end
end
