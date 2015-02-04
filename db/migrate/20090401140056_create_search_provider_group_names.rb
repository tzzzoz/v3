class CreateSearchProviderGroupNames < ActiveRecord::Migration
  def self.up
    create_table :search_provider_group_names do |t|
      t.string :name, :null => false
      t.references :user
      t.timestamps
    end
    
    add_index :search_provider_group_names, [:name, :user_id], :unique => true
    
  end

  def self.down
    remove_index :search_provider_group_names, [:name, :user_id]
    drop_table   :search_provider_group_names
  end
end