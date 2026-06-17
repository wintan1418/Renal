class CreateVascularAccesses < ActiveRecord::Migration[8.0]
  def change
    create_table :vascular_accesses do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.integer :access_type, default: 0, null: false   # fistula, graft, catheter
      t.string  :location                                 # e.g. "Left forearm"
      t.date    :created_on
      t.integer :status, default: 0, null: false          # functioning, monitoring, failing, infected, abandoned
      t.date    :last_assessed_on
      t.text    :notes
      t.timestamps
    end
  end
end
