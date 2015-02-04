class AddIndexToStatisticImageId < ActiveRecord::Migration
  def self.up
    add_index :statistics, :image_id
  end

  def self.down
    remove_index :statistics, :image_id
  end
end
