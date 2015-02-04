class NetMessagesIncreaseMessageAndAnswerLength < ActiveRecord::Migration
  def self.up
    change_column :net_messages, :message, :string, :limit => 1974
    change_column :net_messages, :answer, :string, :limit => 1974
  end

  def self.down
    change_column :net_messages, :message, :string, :limit => 255
    change_column :net_messages, :answer, :string, :limit => 255
  end
end
