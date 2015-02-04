class ReplaceOperationWithOperationLabelIdInStatistics < ActiveRecord::Migration
  def self.up
    remove_column :statistics, :operation
    add_column :statistics, :operation_label_id, :integer
  end

  def self.down
    add_column :statistics, :operation, :integer
    remove_column :statistics, :operation_label_id
  end
end
