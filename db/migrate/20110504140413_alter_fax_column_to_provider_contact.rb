class AlterFaxColumnToProviderContact < ActiveRecord::Migration
  def self.up
    change_column :provider_contacts, :fax, :string, :default => nil
  end

  def self.down
    change_column :provider_contacts, :fax, :string, :default => '0'
  end
end
