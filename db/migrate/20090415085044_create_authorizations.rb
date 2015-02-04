class CreateAuthorizations < ActiveRecord::Migration
  def self.up
    create_table :authorizations do |t|
      t.references :permission_label
      t.references :title_provider_group
      t.timestamps
    end
    add_index :authorizations, [:permission_label_id, :title_provider_group_id], :unique => true, :name => 'index_unique_provider_group_authorization'
  end

  def self.down
    remove_index :authorizations, :name => :index_unique_provider_group_authorization
    drop_table :authorizations
  end
end
