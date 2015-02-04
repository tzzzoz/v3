class AddId20minToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :id20min, :string
  end
end
