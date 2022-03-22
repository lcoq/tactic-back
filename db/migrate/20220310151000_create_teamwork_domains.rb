class CreateTeamworkDomains < ActiveRecord::Migration[5.0]
  def change
    create_table :teamwork_domains do |t|
      t.references :user, foreign_key: true, null: false
      t.string :name, null: false, index: true
      t.string :alias, null: false, index: true
      t.string :token, null: false
      t.timestamps null: false
    end
  end
end
