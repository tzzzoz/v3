class RemovePicNameFromImages < ActiveRecord::Migration
  def self.up
    remove_column :images, :pic_name
  end

  def self.down
    add_column :images, :pic_name, :string
  end
end
