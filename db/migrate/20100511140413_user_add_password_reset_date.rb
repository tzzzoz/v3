class UserAddPasswordResetDate < ActiveRecord::Migration
  def self.up
    add_column :users, :password_updated_at, :date
  end

  def self.down
    remove_column :users, :password_updated_at
  end
end
