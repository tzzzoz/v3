class CreateSelectedProvidersForRequests < ActiveRecord::Migration
  def self.up
    create_table :selected_providers_for_requests do |t|
      t.integer :request_to_provider_id, :provider_id
      t.timestamps
    end
  end

  def self.down
    drop_table :selected_providers_for_requests
  end
end
