class AddHrSizeToImages < ActiveRecord::Migration
  def change
    add_column :images, :hr_size, :integer, :default => 0
  end
end
