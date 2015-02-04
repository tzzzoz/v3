class CreateTitleProviderGroups < ActiveRecord::Migration
  def self.up
    create_table :title_provider_groups do |t|
      t.references :title_provider_group_name, :provider
      t.timestamps
    end
  end

  def self.down
    drop_table :title_provider_groups
  end
end
