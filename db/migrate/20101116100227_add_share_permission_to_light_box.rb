class AddSharePermissionToLightBox < ActiveRecord::Migration
  def self.up
    add_column :light_boxes, :permission, :tinyint, :default => 0 # 0: unshared, 1: shared r, 2: shared rw
  end

  def self.down
    remove_column :light_boxes, :permission
  end
end
