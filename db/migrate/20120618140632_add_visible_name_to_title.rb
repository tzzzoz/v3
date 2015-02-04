class AddVisibleNameToTitle < ActiveRecord::Migration
  def self.up
    change_table  :titles do |t|
      t.column  :visible_name,         :string,  :limit => 100,  :default => ""
    end
  end
  def self.down
    change_table  :titles do |t|
      t.remove  :visible_name
    end
  end
end
