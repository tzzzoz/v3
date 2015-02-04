class CreateProviderContacts < ActiveRecord::Migration
def self.up
    create_table :provider_contacts do |t|
      t.boolean :main
      t.string :first_name
      t.string :last_name
      t.string :email,  :limit => 100
      t.string :fax, :phone, :default => 0
      t.boolean :receive_requests
      t.references :provider

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_contacts
  end
end
