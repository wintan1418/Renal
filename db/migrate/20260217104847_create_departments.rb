class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.text :description
      t.bigint :head_of_department_id
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :departments, :name, unique: true
    add_foreign_key :departments, :users, column: :head_of_department_id
  end
end
