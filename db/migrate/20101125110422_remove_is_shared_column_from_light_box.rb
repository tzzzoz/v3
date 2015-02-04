class RemoveIsSharedColumnFromLightBox < ActiveRecord::Migration
  def self.up
    remove_column :light_boxes, :is_shared
  end

  def self.down
    add_column :light_boxes, :is_shared, :boolean, :default => false
  end
end
