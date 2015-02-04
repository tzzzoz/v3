class RemoveAltLangDescriptionIdFromImages < ActiveRecord::Migration
  def self.up
    remove_column :images, :alt_lang_description_id
  end

  def self.down
    add_column :images, :alt_lang_description_id, :integer, :default => 0
  end
end
