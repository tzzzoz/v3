class AddIndexToStatisticUserId < ActiveRecord::Migration
  def self.up
    add_index :statistics, :user_id
  end

  def self.down
    remove_index :statistics, :user_id
  end
end
