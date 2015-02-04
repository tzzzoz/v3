class CreateProviderForSearchStats < ActiveRecord::Migration
  def up
    create_table :provider_for_search_stats, :force => true do |t|
      t.integer :search_stat_id, :default => 0
      t.integer :provider_id, :default => 0
      t.integer :result, :default => 0
    end
    add_index :provider_for_search_stats, :search_stat_id
    add_index :provider_for_search_stats, :provider_id
  end

  def self.down
    drop_table :provider_for_search_stats
  end
end
