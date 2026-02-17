class CreateLabTests < ActiveRecord::Migration[8.0]
  def change
    create_table :lab_tests do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :category, default: 0, null: false
      t.string :unit
      t.decimal :normal_range_min, precision: 10, scale: 2
      t.decimal :normal_range_max, precision: 10, scale: 2
      t.integer :price_cents, default: 0, null: false
      t.text :description
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    add_index :lab_tests, :code, unique: true
    add_index :lab_tests, :category
  end
end
