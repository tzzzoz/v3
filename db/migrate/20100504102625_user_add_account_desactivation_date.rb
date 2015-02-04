class UserAddAccountDesactivationDate < ActiveRecord::Migration
  def self.up
    add_column :users, :deactivation_at, :date
  end

  def self.down
    remove_column :users, :deactivation_at
  end
end
