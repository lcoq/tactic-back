class CreateUserNotifications < ActiveRecord::Migration[5.0]

  NATURE_TYPE_NAME = "user_notification_nature"
  STATUS_TYPE_NAME = "user_notification_status"

  def up
    execute "CREATE TYPE #{NATURE_TYPE_NAME} AS ENUM ('info', 'warning', 'error');"
    execute "CREATE TYPE #{STATUS_TYPE_NAME} AS ENUM ('unread', 'read');"
    create_table :user_notifications do |t|
      t.references :user, foreign_key: true, null: false
      t.references :resource, polymorphic: true
      t.column :nature, :user_notification_nature, null: false, default: 'info'
      t.column :status, :user_notification_status, null: false, default: 'unread'
      t.string :title
      t.text :message
      t.timestamps null: false
    end
  end

  def down
    drop_table :user_notifications
    execute "DROP TYPE #{NATURE_TYPE_NAME}"
    execute "DROP TYPE #{STATUS_TYPE_NAME}"
  end
end
