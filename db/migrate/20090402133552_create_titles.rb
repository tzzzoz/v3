class CreateTitles < ActiveRecord::Migration
  def self.up
    create_table :titles do |t|
      t.string     :name
      t.boolean :hide_unauthorized_providers, :default => true
      t.integer :dpi, :default => 150
      t.string :flow_path
      t.references :title_provider_group_name
      t.references :server
      t.references :country
      t.timestamps
    end
  end

  def self.down
    drop_table :titles
  end
end
