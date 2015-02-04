class CreateLightBoxPermissionLabels < ActiveRecord::Migration
  def self.up
    create_table :light_box_permission_labels do |t|
      t.string :label, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :light_box_permission_labels
  end
end
