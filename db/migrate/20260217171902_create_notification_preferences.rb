class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :notification_type, null: false
      t.boolean :email_enabled, null: false, default: true
      t.boolean :sms_enabled, null: false, default: false
      t.boolean :in_app_enabled, null: false, default: true

      t.timestamps
    end

    add_index :notification_preferences, [ :user_id, :notification_type ], unique: true,
              name: "idx_notification_prefs_user_type"
  end
end
