class AddContentErrorToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :content_error, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :images, :content_error    
  end
end
