class CreateMetadataConversions < ActiveRecord::Migration
  def self.up
    create_table :metadata_conversions do |t|
      t.string :image
      t.string :iptc
      t.string :eightbim
      t.string :xmp
    end
  end

  def self.down
    drop_table :metadata_conversions
  end
end
