class CreateReportagePhotos < ActiveRecord::Migration
  def up
    create_table :reportage_photos, :force => true do |t|
      t.integer :reportage_id
      t.integer :photo_ms_id
      t.integer :rang, :default => 0
    end
    add_index :reportage_photos, :reportage_id
    add_index :reportage_photos, :photo_ms_id
  end

  def self.down
    drop_table :reportage_photos
  end
end
