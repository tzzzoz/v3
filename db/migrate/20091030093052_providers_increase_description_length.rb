class ProvidersIncreaseDescriptionLength < ActiveRecord::Migration
  def self.up
    change_column :providers, :description, :string, :limit => 750
  end

  def self.down
    change_column :providers, :description, :string, :limit => 150
  end
end
