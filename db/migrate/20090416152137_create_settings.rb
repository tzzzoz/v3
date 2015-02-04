class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string  :language
      t.text    :preferential_corpus
      t.text    :display_params
      t.text    :border_color_provider
      t.integer :user_id
      t.timestamps
    end
    add_index :settings, :user_id
  end

  def self.down
    drop_table :settings
  end
end
