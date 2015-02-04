class CreateSearchStats < ActiveRecord::Migration
  def up
    create_table :search_stats, :force => true do |t|
      t.string :keyword,  :limit => 255
      t.string :since, :limit => 50
      t.string :tri,   :limit => 50
      t.date :date_pp_from, :null => true
      t.date :date_pp_to, :null => true
      t.date :date_photo_from, :null => true
      t.date :date_photo_to, :null => true
      t.integer :format
      t.integer :result, :default => 0
      t.integer :user_id
      t.datetime :created_at
    end
    add_index :search_stats, :user_id
    add_index :search_stats, :result
  end

  def self.down
    drop_table :search_stats
  end
end
