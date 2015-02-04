class CreateOperationLabels < ActiveRecord::Migration
  def self.up
    create_table :operation_labels do |t|
      t.string :label # 'BD', 'HD', etc...
      t.timestamps
    end
  end

  def self.down
    drop_table :operation_labels
  end
end
