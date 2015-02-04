class AddPerPageToSetting < ActiveRecord::Migration
  def self.up
    add_column :settings, :default_per_page, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :settings, :default_per_page
  end

end
