class UserMigrateToAuthlogic < ActiveRecord::Migration
  def self.up
    change_column :users, :crypted_password, :string, :limit => 128,
      :null => false, :default => ""
    change_column :users, :salt, :string, :limit => 128,
      :null => false, :default => ""

    add_column :users, :persistence_token, :string, :null => false
    add_column :users, :perishable_token, :string, :null => false
    add_column :users, :login_count, :integer
    add_column :users, :failed_login_count, :integer
    add_column :users, :last_request_at, :datetime
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string

    remove_column :users, :activation_code
    remove_column :users, :remember_token
  end

  def self.down
    change_column :users, :crypted_password, :string, :limit => 40
    change_column :users, :salt, :string, :limit => 40

    remove_column :users, :persistence_token
    remove_column :users, :perishable_token
    remove_column :users, :login_count
    remove_column :users, :failed_login_count
    remove_column :users, :last_request_at
    remove_column :users, :current_login_at
    remove_column :users, :last_login_at
    remove_column :users, :current_login_ip
    remove_column :users, :last_login_ip

    add_column :users, :activation_code, :string, :limit => 40
    add_column :users, :remember_token, :string, :limit => 40
  end

end
