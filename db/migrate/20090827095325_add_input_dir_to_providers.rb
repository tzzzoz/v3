class AddInputDirToProviders < ActiveRecord::Migration
  def self.up
    add_column :providers, :input_dir, :string
  end

  def self.down
    remove_column :providers, :input_dir
  end
end
