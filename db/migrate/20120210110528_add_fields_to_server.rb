class AddFieldsToServer < ActiveRecord::Migration
  def self.up
    change_table :servers do |t|
      t.column   :api_key,  :string
      t.column   :api_port, :string, :default => "5671", :null => false
    end
  end

  def self.down
    change_table :servers do |t|
      t.remove   :api_key
      t.remove   :api_port
    end
  end
end
