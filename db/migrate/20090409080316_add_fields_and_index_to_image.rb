class AddFieldsAndIndexToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :rights, :string, :limit => 384
    add_column :images, :category, :string, :limit => 9
    add_column :images, :supplemental_category, :string, :limit => 96
    add_column :images, :urgency, :integer, :limit => 3
    add_column :images, :authors_position, :string, :limit => 96
    add_column :images, :transmission_reference, :string, :limit => 96
    add_column :images, :caption_writer, :string, :limit => 96    
    add_index  :images, [:original_filename,:provider_id],  :unique => true
  end

  def self.down
    remove_column :images, :rights
    remove_column :images, :category
    remove_column :images, :supplemental_category
    remove_column :images, :urgency
    remove_column :images, :authors_position
    remove_column :images, :transmission_reference
    remove_column :images, :caption_writer    
    remove_index  :images, [:original_filename,:provider_id]
  end
end
