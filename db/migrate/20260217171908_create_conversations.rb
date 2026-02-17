class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.string :subject, null: false
      t.integer :status, null: false, default: 0  # 0=open, 1=closed

      t.timestamps
    end

    add_index :conversations, :status
  end
end
