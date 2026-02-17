class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.references :department, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false, default: 0
      t.integer :duration_minutes, default: 30
      t.integer :service_type, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
