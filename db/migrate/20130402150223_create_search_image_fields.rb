class CreateSearchImageFields < ActiveRecord::Migration
  def up
    create_table :search_image_fields, :force => true do |t|
      t.integer :search_stat_id, :default => 0
      t.string :field_name, :limit => 50
      t.string :field_content, :limit => 100
    end
    add_index :search_image_fields, :search_stat_id
  end

  def self.down
    drop_table :search_image_fields
  end
end
