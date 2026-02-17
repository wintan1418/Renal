class CreateHospitals < ActiveRecord::Migration[8.0]
  def change
    create_table :hospitals do |t|
      t.string :name, null: false
      t.text :address
      t.string :city
      t.string :state
      t.string :country, default: "Nigeria"
      t.string :phone
      t.string :email
      t.string :website
      t.string :currency, default: "NGN"
      t.string :timezone, default: "Africa/Lagos"
      t.time :opening_time
      t.time :closing_time

      t.timestamps
    end
  end
end
