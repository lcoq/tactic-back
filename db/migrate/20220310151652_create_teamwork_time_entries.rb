class CreateTeamworkTimeEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :teamwork_time_entries do |t|
      t.references :entry, foreign_key: false, null: false, index: { unique: true }
      t.references :teamwork_domain, foreign_key: true, null: false
      t.bigint :time_entry_id, null: false, index: { unique: true }
      t.timestamps null: false
    end
  end
end
