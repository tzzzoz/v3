class AddRequestToImageAndRequestToProviders < ActiveRecord::Migration
  def self.up
    add_column :images, :private_image, :boolean, :default => false
    add_column :request_to_providers, :serial, :string
  end

  def self.down
    remove_column :images, :private_image
    remove_column :request_to_providers, :serial
  end
end
