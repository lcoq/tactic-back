class RemoveNotNullConstraintOnEntriesStoppedAt < ActiveRecord::Migration[5.0]
  def change
    change_column_null :entries, :stopped_at, true
  end
end
