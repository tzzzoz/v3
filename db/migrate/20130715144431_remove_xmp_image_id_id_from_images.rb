class RemoveXmpImageIdIdFromImages < ActiveRecord::Migration
  def self.up
    remove_column :images, :xmp_image_id
  end

  def self.down
    add_column :images, :xmp_image_id, :integer, :default => 0
  end
end
