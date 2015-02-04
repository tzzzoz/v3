class NetMessagesMessageAndAnswerToText < ActiveRecord::Migration
  def self.up
    change_column :net_messages, :message, :text
    change_column :net_messages, :answer, :text
  end

  def self.down
    change_column :net_messages, :message, :string, :limit => 1974
    change_column :net_messages, :answer, :string, :limit => 1974
  end
end
