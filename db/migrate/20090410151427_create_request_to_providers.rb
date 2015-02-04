class CreateRequestToProviders < ActiveRecord::Migration
  def self.up
    create_table :request_to_providers do |t|
      t.string :text
      t.date :view_date
      t.string :status, :subject
      t.integer :responses_count
      t.references :user
      t.timestamps
    end
    
    add_index :request_to_providers, :user_id
    
  end

  def self.down
    remove_index :request_to_providers, :user_id
    drop_table :request_to_providers
  end
end
