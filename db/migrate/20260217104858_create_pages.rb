class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :body
      t.text :meta_description
      t.boolean :published, default: false
      t.references :author, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :pages, :slug, unique: true
  end
end
