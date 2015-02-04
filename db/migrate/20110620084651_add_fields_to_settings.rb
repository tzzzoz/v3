class AddFieldsToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :default_since, :string, :null => false, :default => "all"
    add_column :settings, :default_sort, :string, :null => false, :default => "reception_date"
  end

  def self.down
    remove_column :settings, :default_since
    remove_column :settings, :default_sort
  end
end
