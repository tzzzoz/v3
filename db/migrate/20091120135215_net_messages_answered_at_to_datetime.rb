class NetMessagesAnsweredAtToDatetime < ActiveRecord::Migration
  def self.up
    change_column :net_messages, :answered_at, :datetime
  end

  def self.down
    change_column :net_messages, :answered_at, :date
  end
end
