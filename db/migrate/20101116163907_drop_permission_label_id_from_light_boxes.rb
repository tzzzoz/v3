class DropPermissionLabelIdFromLightBoxes < ActiveRecord::Migration
  def self.up
    remove_column :light_boxes, :light_box_permission_label_id
  end

  def self.down
    add_column :light_boxes, :light_box_permission_label_id, :integer
  end
end
