class CreateTitleProviderGroupNames < ActiveRecord::Migration
  def self.up
    create_table :title_provider_group_names do |t|
      t.string :name
      t.references :country
      t.timestamps
    end

    add_index :title_provider_group_names, [:name, :country_id], :unique => true
  end

  def self.down
    remove_index :title_provider_group_names, [:name, :country_id]
    drop_table :title_provider_group_names
  end
end
