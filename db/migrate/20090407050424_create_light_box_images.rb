class CreateLightBoxImages < ActiveRecord::Migration
  def self.up
    create_table :light_box_images do |t|
      t.string :annotation
      t.integer :light_box_id
      t.integer :image_id
      t.column :position,   :integer 

      t.timestamps
    end
    add_index :light_box_images, :light_box_id
    add_index :light_box_images, :image_id
  end

  def self.down
    drop_table :light_box_images
  end
end
