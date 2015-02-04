class AlterImageRestrictionsDefault < ActiveRecord::Migration
  def self.up
    change_column :images, :restrictions, :string, :limit => 512, :default => 'ANY'
  end

  def self.down
    change_column :images, :restrictions, :string, :limit => 512
  end
end
