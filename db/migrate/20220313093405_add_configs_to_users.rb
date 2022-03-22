class AddConfigsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :configs, :json
  end
end
