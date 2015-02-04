class CreateStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics do |t|
      t.string :operation
      t.references :user, :image
      t.timestamps
    end
  end

  def self.down
    drop_table :statistics
  end
end
