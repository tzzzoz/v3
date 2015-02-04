class AddHasFormAndFormPerSessionToProvider < ActiveRecord::Migration
  def self.up
    add_column :providers, :has_form, :boolean, :default => false
    add_column :providers, :form_per_session, :boolean, :default => false
    add_column :providers, :provider_conditions, :string,  :limit => 255    
  end

  def self.down
  end
end
