class DropLightBoxPermissionLabel < ActiveRecord::Migration
  def self.up
    drop_table :light_box_permission_labels
  end

  def self.down
    # Unreversible change
  end
end
