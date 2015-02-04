class AddRatioToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :ratio, :float
  end

  def self.down
    remove_column :images, :ratio
  end
end
