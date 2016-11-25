class CreateSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, index: true
      t.string :token, null: false, index: { unique: true }
      t.timestamps null: false
    end
  end
end
