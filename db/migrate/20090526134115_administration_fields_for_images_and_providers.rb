class AdministrationFieldsForImagesAndProviders < ActiveRecord::Migration
  def self.up
    add_column :providers, :days_keep, :integer, :default => nil
    add_column :providers, :days_keep_per_picture, :boolean, :default => false    
    add_column :images, :erasable, :boolean, :default => false    
    add_column :images, :ms_picture_id, :string
    add_column :images, :ms_id, :string
  end

  def self.down
    remove_column :providers, :days_keep
    remove_column :providers, :days_keep_per_picture    
    remove_column :images, :erasable
    remove_column :images, :ms_picture_id
    remove_column :images, :ms_id    
  end
end
