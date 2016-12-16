class AddArchivedToClients < ActiveRecord::Migration[5.0]
  def change
    add_column :clients, :archived, :boolean, null: false, default: false, index: true
    add_index :clients, :archived
  end
end
