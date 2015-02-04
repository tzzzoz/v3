class AddCityZipCodeAndCountryToProviders < ActiveRecord::Migration
  def self.up
    add_column :providers, :city, :string
    add_column :providers, :country, :string
    add_column :providers, :zip_code, :string
  end

  def self.down
    remove_column :providers, :city
    remove_column :providers, :country
    remove_column :providers, :zip_code
  end
end
