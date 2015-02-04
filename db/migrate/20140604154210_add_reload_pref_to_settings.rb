class AddReloadPrefToSettings < ActiveRecord::Migration
  def change
	add_column :settings, :reload_pref, :integer, :default => 0
  end
end
