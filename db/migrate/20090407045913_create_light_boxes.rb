class CreateLightBoxes < ActiveRecord::Migration
  def self.up
    create_table :light_boxes do |t|
      # a lightbox is globally shared by a user for his title
      t.boolean :is_shared, :default => false
      t.boolean :order_by_agency, :default => false
      t.string :name
      t.references :user
      t.references :title
      t.string :hash_code
      t.integer :items_count, :default => 0
      t.timestamps
    end
    add_index :light_boxes, :name
    add_index :light_boxes, :user_id
  end

  def self.down
    drop_table :light_boxes
  end
end
