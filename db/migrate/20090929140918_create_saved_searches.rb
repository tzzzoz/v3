class CreateSavedSearches < ActiveRecord::Migration
  def self.up
    create_table :saved_searches do |t|
      t.references :user
      t.string     :name
      t.timestamp  :date
      t.timestamp  :date_last_search
      t.integer    :photos_count
      t.text       :criteria
      t.timestamps
    end
  end

  def self.down
    drop_table :saved_searches
  end
end
