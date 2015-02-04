class AddGroupAndTypeToTitles < ActiveRecord::Migration
  def self.up
    change_table  :titles do |t|
      t.column  :group,         :string,  :limit => 100,  :default => ""
      t.column  :title_type,    :string,  :limit => 100,  :default => ""
      end
  end
  def self.down
    change_table  :titles do |t|
      t.remove  :group
      t.remove  :title_type
      end
  end
end
