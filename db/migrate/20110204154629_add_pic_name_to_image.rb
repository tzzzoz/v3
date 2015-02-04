class AddPicNameToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :pic_name, :string
    add_index  :images, :pic_name
  end

  def self.down
    remove_index  :images, :pic_name
    remove_column :images, :pic_name
  end
end
