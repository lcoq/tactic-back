class CreateTeamworkUserConfigSets < ActiveRecord::Migration[5.0]
  def change
    create_table :teamwork_user_config_sets do |t|
      t.references :user, foreign_key: true, null: false
      t.json :set, null: false, default: {}
      t.timestamps null: false
    end
  end
end
