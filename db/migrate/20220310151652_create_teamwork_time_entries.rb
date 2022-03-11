class CreateTeamworkTimeEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :teamwork_time_entries do |t|
      t.references :entry, foreign_key: true, null: false, index: { unique: true }
      t.bigint :time_entry_id, null: false, index: { unique: true }
      t.timestamps null: false
    end
  end
end
