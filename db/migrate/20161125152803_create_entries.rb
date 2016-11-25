class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :entries do |t|
      t.references :user, null: false, index: true
      t.string :title
      t.datetime :started_at, null: false
      t.datetime :stopped_at, null: false
      t.timestamps null: false
    end
  end
end
