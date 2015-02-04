class AddPageRefToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :page_ref, :string, :limit => 150, :default => nil
  end

  def self.down
    remove_column :images, :page_ref, :string
  end
end
