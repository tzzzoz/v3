class AddDeltaToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :images, :delta
  end
end