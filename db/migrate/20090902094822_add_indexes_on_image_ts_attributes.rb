class AddIndexesOnImageTsAttributes < ActiveRecord::Migration
  def self.up
    add_index :images, :ratio
    add_index :images, :date_created
    add_index :images, :created_at
    add_index :images, :updated_at
    add_index :images, :private_image
  end

  def self.down
    remove_index :images, :ratio
    remove_index :images, :date_created
    remove_index :images, :created_at
    remove_index :images, :updated_at
    remove_index :images, :private_image
  end
end
