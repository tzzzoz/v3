class AddDeltaToStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :delta, :boolean, :default => true
  end

  def self.down
    remove_column :statistics, :delta
  end
end
