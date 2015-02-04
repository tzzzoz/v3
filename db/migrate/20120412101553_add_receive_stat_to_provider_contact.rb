class AddReceiveStatToProviderContact < ActiveRecord::Migration
  def self.up
    add_column :provider_contacts, :receive_stat, :boolean
  end

  def self.down
    remove_column :provider_contacts, :receive_stat, :boolean
  end
end
