class CreateClients < ActiveRecord::Migration[5.0]
  def change
    create_table :clients do |t|
      t.string :name, null: false, index: { unique: true }
      t.timestamps null: false
    end
    add_reference :projects, :client, index: true
  end
end
