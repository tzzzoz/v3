class AddLightBoxPermissionLabelReferenceToLightbox < ActiveRecord::Migration
  def self.up
    change_table :light_boxes do |t|
      t.references :light_box_permission_label
    end
  end

  def self.down
    change_table :light_boxes do |t|
      t.remove_references :light_box_permission_label
    end
  end
end
