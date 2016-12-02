class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false, index: { unique: true }
      t.timestamps null: false
    end
    add_reference :entries, :project, index: true
  end
end
