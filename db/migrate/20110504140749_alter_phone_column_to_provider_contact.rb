class AlterPhoneColumnToProviderContact < ActiveRecord::Migration
  def self.up
    change_column :provider_contacts, :phone, :string, :default => nil
  end

  def self.down
    change_column :provider_contacts, :phone, :string, :default => '0'
  end
end
