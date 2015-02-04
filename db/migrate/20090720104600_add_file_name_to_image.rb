class AddFileNameToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :file_name, :string
    add_index  :images, :file_name
  end

  def self.down
    remove_index  :images, :file_name
    remove_column :images, :file_name
  end
end
