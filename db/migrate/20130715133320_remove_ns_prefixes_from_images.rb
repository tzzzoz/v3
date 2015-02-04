class RemoveNsPrefixesFromImages < ActiveRecord::Migration
  def self.up
    remove_column :images, :ns_prefixes
  end

  def self.down
    add_column :images, :ns_prefixes, :string
  end
end
