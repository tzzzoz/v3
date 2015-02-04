class CreatePermissionLabels < ActiveRecord::Migration
  def self.up
    create_table :permission_labels do |t|
      t.string :label # 'hd_download', 'ld_download', etc...
      t.timestamps
    end
  end

  def self.down
    drop_table :permission_labels
  end
end
