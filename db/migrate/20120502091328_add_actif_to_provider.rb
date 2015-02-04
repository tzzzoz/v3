class AddActifToProvider < ActiveRecord::Migration
  def self.up
    add_column :providers, :actif, :boolean, :default => true
  end

  def self.down
    remove_column :providers, :actif, :boolean
  end
end
