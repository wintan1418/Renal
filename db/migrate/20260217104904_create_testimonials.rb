class CreateTestimonials < ActiveRecord::Migration[8.0]
  def change
    create_table :testimonials do |t|
      t.string :patient_name, null: false
      t.text :content, null: false
      t.integer :rating
      t.boolean :approved, default: false

      t.timestamps
    end
  end
end
