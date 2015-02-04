class AddPortableToProviderContacts < ActiveRecord::Migration
  def self.up
    add_column :provider_contacts, :portable, :string
  end

  def self.down
    remove_column :provider_contacts, :portable
  end
end
