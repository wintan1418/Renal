class CreateDialysisConsumables < ActiveRecord::Migration[8.0]
  def change
    create_table :dialysis_consumables do |t|
      t.string :name, null: false
      t.integer :category, null: false, default: 0  # 0=dialyzer, 1=bloodlines, 2=needles, 3=solutions, 4=medications, 5=other
      t.string :unit, null: false, default: "piece"
      t.decimal :quantity_in_stock, precision: 10, scale: 2, null: false, default: 0
      t.decimal :reorder_level, precision: 10, scale: 2, null: false, default: 0
      t.integer :unit_cost_cents, null: false, default: 0
      t.string :supplier
      t.text :description
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :dialysis_consumables, :category
    add_index :dialysis_consumables, :active
  end
end
