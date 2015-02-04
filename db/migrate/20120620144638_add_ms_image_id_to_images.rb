class AddMsImageIdToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :ms_image_id, :integer, :default => 0
  end

  def self.down
    remove_column :images, :ms_image_id
  end
end
