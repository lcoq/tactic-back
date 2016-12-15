class AddArchivedToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :archived, :boolean, null: false, default: false, index: true
    add_index :projects, :archived
  end
end
