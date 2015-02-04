class CreateProviders < ActiveRecord::Migration
  def self.up
    create_table :providers do |t|
      t.string  :name
      t.string  :logo # reference le logo uploader
      t.string  :description,  :limit => 150
      t.string  :form_path,  :limit => 255
      t.string  :site, :address
      t.boolean :local, :default => false
      t.string  :copyright_rule
      t.string  :string_key
      t.timestamps
# TODO sami : règles de gestion/indexation, à voir plus tard ?
#      t.string :input_dir
#      t.integer :scan_period
#      t.integer :news_keeping_time # if 0 keep forever (in days)
#      t.integer :news_max_count # max number of pictures kept for news. 0 = unlimited
#      t.integer :stock_keeping_time # if 0 keep forever (in days)
#      t.integer :stock_max_count  # max number of picture kept for stock. 0 = unlimited
#      t.string :hires_url,  :limit => 255
    end
  end

  def self.down
    drop_table :providers
  end
end
