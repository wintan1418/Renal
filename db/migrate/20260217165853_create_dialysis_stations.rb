class CreateDialysisStations < ActiveRecord::Migration[8.0]
  def change
    create_table :dialysis_stations do |t|
      t.string :name, null: false
      t.integer :station_type, null: false, default: 0  # 0=chair, 1=bed
      t.integer :status, null: false, default: 0        # 0=available, 1=occupied, 2=cleaning, 3=maintenance
      t.text :notes

      t.timestamps
    end

    add_index :dialysis_stations, :status
  end
end
