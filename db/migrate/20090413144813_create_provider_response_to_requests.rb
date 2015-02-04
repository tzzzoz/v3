class CreateProviderResponseToRequests < ActiveRecord::Migration
  def self.up
    create_table :provider_response_to_requests do |t|
      t.integer :request_to_provider_id
      t.integer :image_id
      t.timestamps
    end
    
    add_index :provider_response_to_requests, :request_to_provider_id
  end

  def self.down
    drop_table :provider_response_to_requests
  end
end
