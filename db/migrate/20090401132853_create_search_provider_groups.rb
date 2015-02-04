class CreateSearchProviderGroups < ActiveRecord::Migration
  def self.up
    create_table :search_provider_groups do |t|
    t.references :provider, :search_provider_group_name
    t.timestamps
    end
  end

  def self.down
    drop_table :search_provider_groups
  end
end
