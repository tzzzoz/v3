class AlterUserPhone < ActiveRecord::Migration
  def self.up
    change_column :users, :phone, :string
  end

  def self.down
    change_column :users, :phone, :integer
  end
end
