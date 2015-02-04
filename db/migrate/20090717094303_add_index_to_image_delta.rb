class AddIndexToImageDelta < ActiveRecord::Migration
  def self.up
    add_index :images, :delta
  end

  def self.down
    remove_index :images, :delta
  end
end
