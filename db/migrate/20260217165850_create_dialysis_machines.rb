class CreateDialysisMachines < ActiveRecord::Migration[8.0]
  def change
    create_table :dialysis_machines do |t|
      t.string :name, null: false
      t.string :serial_number, null: false
      t.string :model
      t.string :manufacturer
      t.integer :status, null: false, default: 0  # 0=available, 1=in_use, 2=maintenance, 3=retired
      t.date :last_serviced_on
      t.date :next_service_due
      t.text :notes

      t.timestamps
    end

    add_index :dialysis_machines, :serial_number, unique: true
    add_index :dialysis_machines, :status
  end
end
