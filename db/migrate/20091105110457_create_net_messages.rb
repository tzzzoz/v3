class CreateNetMessages < ActiveRecord::Migration
  def self.up
    create_table    :net_messages do |t|
      t.string      :message, :null => false
      t.string      :answer
      t.date        :answered_at
      t.boolean     :skipable, :default => false, :null => false
      t.references  :server
      t.timestamps
    end
  end

  def self.down
    drop_table :net_messages
  end
end
