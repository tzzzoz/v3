class AddFondsToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :fonds, :integer, :default => 0
  end

  def self.down
    remove_column :images, :fonds, :integer
  end
end
