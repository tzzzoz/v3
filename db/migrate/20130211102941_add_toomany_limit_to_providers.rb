class AddToomanyLimitToProviders < ActiveRecord::Migration
  def self.up
    change_table  :providers do |t|
      t.column  :toomany_limit,         :integer,  :default => 0
    end
  end
  def self.down
    change_table  :providers do |t|
      t.remove  :toomany_limit
    end
  end
end
